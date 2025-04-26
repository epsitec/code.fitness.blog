# code.fitness.blog

Source for the blog hosted at <http://code.fitness>.

The static content is built with [Hugo](https://gohugo.io/).

See [Hugo First Steps](http://code.fitness/2015/11/hugo-first-steps/) for more information
about how the Markdown content is used to generate HTML pages.

## Serve the web site as HTTPS with HSTS enabled

Add an `.htaccess` file with following content:

```apache
<IfModule mod_headers.c>
  Header always set Strict-Transport-Security "max-age=16000000; includeSubDomains;"
</IfModule>

RewriteEngine on
RewriteCond %{HTTP:X-Forwarded-Proto} !https [OR]
RewriteCond %{HTTP_HOST} ^www. [NC]
RewriteRule (.*) https://code.fitness/$1 [R=301,L]
```

## Site Deployment

The site deployment process involves two steps:

1. Generate the static site using Hugo
2. Upload the generated content to the production server via FTP

### Generation

To generate the static site, run:

```batch
.\hugo-pub.bat
```

This script:
- Cleans the `./site/public` directory
- Runs Hugo to generate fresh content
- Places the generated site in `./site/public`

### Uploading to Production

After generating the site, use the PowerShell script to upload it:

```powershell
.\hugo-upload.ps1 -Password "your-secure-password"
```

This script:
- Validates that `./site/public` exists
- Connects to the FTP server using the credentials
- Uploads all files maintaining the directory structure
- Provides progress reporting
- Summarizes the upload results

#### Advanced Options

The upload script supports additional parameters:

```powershell
.\hugo-upload.ps1 -Password "your-secure-password" -FtpServer "ftp.example.com" -RemoteRoot "/www"
```

Parameters:
- `-Password`: (Required) The FTP password
- `-FtpServer`: (Optional) Override the default FTP server (default: ftp.code.fitness)
- `-RemoteRoot`: (Optional) Override the remote root directory (default: /)

### Workflow Example

A typical workflow for updating the blog:

1. Create new content
2. Test locally with `.\hugo-run.bat`
3. Generate production files with `.\hugo-pub.bat`
4. Upload to production with `.\hugo-upload.ps1 -Password "your-password"`
