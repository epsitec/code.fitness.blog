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
