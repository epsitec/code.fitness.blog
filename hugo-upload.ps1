#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Uploads the Hugo generated site to the production FTP server.

.DESCRIPTION
    This script uploads the contents of the ./site/public directory to the production FTP server
    using the specified credentials. The directory structure is maintained during the upload.

.PARAMETER Password
    The password for the FTP account. The username is fixed as 'kvoz_fitness'.

.PARAMETER FtpServer
    The FTP server address. Defaults to 'ftp.code.fitness'.

.PARAMETER RemoteRoot
    The root directory on the FTP server. Defaults to '/'.

.EXAMPLE
    .\hugo-upload.ps1 -Password "your-secure-password"

.EXAMPLE
    .\hugo-upload.ps1 -Password "your-secure-password" -FtpServer "ftp.example.com" -RemoteRoot "/www"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Password,
    
    [Parameter(Mandatory = $false)]
    [string]$FtpServer = "code.fitness",
    
    [Parameter(Mandatory = $false)]
    [string]$RemoteRoot = "/"
)

# Fixed username
$Username = "kvoz_fitness"

# Local directory containing the Hugo-generated site
$LocalRoot = Join-Path (Get-Location) "site\public"

# Validate the local directory exists
if (-not (Test-Path -Path $LocalRoot -PathType Container)) {
    Write-Error "The directory '$LocalRoot' does not exist. Please run hugo-pub.bat first to generate the site."
    exit 1
}
# Function to create a directory on the FTP server
function New-FtpDirectory {
    param (
        [string]$ftpUrl,
        [string]$username,
        [string]$password
    )
    
    # Normalize the FTP URL
    $ftpUrl = $ftpUrl.Replace("\", "/").Replace("//", "/")
    if ($ftpUrl -match "ftp:/[^/]") {
        $ftpUrl = $ftpUrl.Replace("ftp:/", "ftp://")
    }
    
    try {
        $request = [System.Net.WebRequest]::Create($ftpUrl)
        $request.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
        $request.Credentials = New-Object System.Net.NetworkCredential($username, $password)
        
        $response = $request.GetResponse()
        $response.Close()
        return $true
    }
    catch [System.Net.WebException] {
        # Directory might already exist - that's OK
        if ($_.Exception.Response.StatusCode -eq [System.Net.FtpStatusCode]::ActionNotTakenFileUnavailable) {
            return $true
        }
        return $false
    }
}

# Function to upload a file to the FTP server
function Send-FtpFile {
    param (
        [string]$localFile,
        [string]$ftpUrl,
        [string]$username,
        [string]$password
    )
    
    # Normalize the FTP URL
    $ftpUrl = $ftpUrl.Replace("\", "/").Replace("//", "/")
    if ($ftpUrl -match "ftp:/[^/]") {
        $ftpUrl = $ftpUrl.Replace("ftp:/", "ftp://")
    }
    
    try {
        $webclient = New-Object System.Net.WebClient
        $webclient.Credentials = New-Object System.Net.NetworkCredential($username, $password)
        
        Write-Host "Uploading $localFile to $ftpUrl" -ForegroundColor Cyan
        $webclient.UploadFile($ftpUrl, $localFile)
        return $true
    }
    catch {
        Write-Error "Failed to upload $localFile to $ftpUrl. Error: $_"
        return $false
    }
}

# Function to check if a directory exists on the FTP server
function Test-FtpDirectoryExists {
    param (
        [string]$ftpUrl,
        [string]$username,
        [string]$password
    )
    
    # Normalize the FTP URL
    $ftpUrl = $ftpUrl.Replace("\", "/").Replace("//", "/")
    if ($ftpUrl -match "ftp:/[^/]") {
        $ftpUrl = $ftpUrl.Replace("ftp:/", "ftp://")
    }
    
    try {
        $request = [System.Net.WebRequest]::Create("$ftpUrl/")
        $request.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectoryDetails
        $request.Credentials = New-Object System.Net.NetworkCredential($username, $password)
        
        $response = $request.GetResponse()
        $response.Close()
        return $true
    }
    catch {
        Write-Host "Testing directory: $ftpUrl/ --> not found" -ForegroundColor Yellow
        return $false
    }
}

# Ensure FTP server URL has trailing slash
if (-not $FtpServer.EndsWith("/")) {
    $FtpServer = "$FtpServer/"
}

if (-not $RemoteRoot.EndsWith("/")) {
    $RemoteRoot = "$RemoteRoot/"
}

# Add ftp:// prefix if missing
if (-not $FtpServer.StartsWith("ftp://")) {
    $FtpServer = "ftp://$FtpServer"
}

Write-Host "Starting FTP upload process..." -ForegroundColor Green
Write-Host "Local root: $LocalRoot" -ForegroundColor Green
Write-Host "FTP server: $FtpServer" -ForegroundColor Green
Write-Host "Remote root: $RemoteRoot" -ForegroundColor Green
Write-Host "Username: $Username" -ForegroundColor Green

# Counter for statistics
$totalFiles = 0
$uploadedFiles = 0
$failedFiles = 0

# Get all files to upload
$files = Get-ChildItem -Path $LocalRoot -Recurse -File
$totalFiles = $files.Count

Write-Host "Found $totalFiles files to upload." -ForegroundColor Yellow

# Process each file
foreach ($file in $files) {
    # Get relative path from local root
    # Get relative path from local root
    $relativePath = $file.FullName.Substring($LocalRoot.Length).Replace("\", "/")
    
    # Ensure path starts with single /
    $relativePath = "/" + $relativePath.TrimStart('/')
    
    # Full remote path - ensure single slashes
    $remotePath = ($RemoteRoot + $relativePath.Substring(1)).Replace("//", "/")
    
    # Remote directory
    $remoteDir = (Split-Path -Parent $remotePath).Replace("\", "/")
    $remoteDir = "/" + $remoteDir.TrimStart('/')
    # Create remote directory if it doesn't exist
    
    # Split the path and create each level
    $pathParts = $remoteDir.Split("/", [System.StringSplitOptions]::RemoveEmptyEntries)
    $currentPath = ""
    
    foreach ($part in $pathParts) {
        $currentPath += "/$part".Replace("//", "/")
        $currentDirUrl = "$FtpServer$currentPath"
        if (-not (Test-FtpDirectoryExists -ftpUrl $currentDirUrl -username $Username -password $Password)) {
            Write-Host "Creating directory: $currentDirUrl" -ForegroundColor Magenta
            $success = New-FtpDirectory -ftpUrl $currentDirUrl -username $Username -password $Password
            
            if (-not $success) {
                Write-Warning "Failed to create directory: $currentDirUrl"
            }
        }
    }
    
    # Upload the file
    $remoteFileUrl = "$FtpServer$remotePath".Replace("//", "/")
    $success = Send-FtpFile -localFile $file.FullName -ftpUrl $remoteFileUrl -username $Username -password $Password
    
    if ($success) {
        $uploadedFiles++
        Write-Progress -Activity "Uploading Files" -Status "Uploaded $uploadedFiles of $totalFiles" -PercentComplete (($uploadedFiles / $totalFiles) * 100)
    }
    else {
        $failedFiles++
    }
}

Write-Progress -Activity "Uploading Files" -Completed

# Summary
Write-Host "Upload completed!" -ForegroundColor Green
Write-Host "Total files: $totalFiles" -ForegroundColor Yellow
Write-Host "Successfully uploaded: $uploadedFiles" -ForegroundColor Green

if ($failedFiles -gt 0) {
    Write-Host "Failed uploads: $failedFiles" -ForegroundColor Red
    exit 1
}
else {
    Write-Host "All files uploaded successfully." -ForegroundColor Green
    exit 0
}

