+++
categories = ["Tools"]
date = "2015-11-17T17:19:00+01:00"
title = "Getting started with Hugo"
+++

I was looking for a blog engine which would take a collection of Markdown
pages and turn them into static pages, which I could then publish on my
[code.fitness](https://code.fitness) site.

I found [Hugo](https://gohugo.io/), which describes itself as:

> Hugo, A Fast & Modern Static Website engine

## Installing Hugo

Hugo consist of a single zipped executable. As I am currently developing
on a Windows machine, I selected `hugo_0.14_windows_386.zip` from
the [releases](https://gohugo.io/) page. But Hugo is also available on
Mac and on Linux.

I extracted the `hugo_0.14_windows_386.exe`, renamed it `hugo.exe` and
put it in my `C:\tools` folder which gets picked up by the `PATH`.

## Creating my initial site

The documentation on [gohugo.io](https://gohugo.io) is plentiful. For the
impatient, there is a [quickstart](https://gohugo.io/overview/quickstart/)
section.

Basically, creating a site is done with `hugo new site` and the name of
the folder where the site should be created. I chose `site` for that too,
so I went with:

```cmd
hugo.exe new site "site"
cd site
```

## Choosing a theme

It took me some time until I settled on a [theme](http://themes.gohugo.io/)
which would best fit my needs. I picked Asuka Suzuki's
[Angel's Ladder](http://themes.gohugo.io/angels-ladder/), which can be
found on [GitHub](https://github.com/tanksuzuki/angels-ladder).

```cmd
mkdir themes
pushd themes
git clone https://github.com/tanksuzuki/angels-ladder.git
popd
```

## Configuring Hugo

The basic configuration is done in file `config.toml`. Here is an excerpt
of what I have come up with:

```
baseURL = "http://code.fitness/"
languageCode = "en"
title = "code.fitness"
theme = "angels-ladder"

[permalinks]
  post = "/:year/:month/:filename/"

[params]
  subtitle = "Good code requires care."
  twitter = "https://twitter.com/epsitec"
  github = "https://github.com/epsitec"
  profile = "/images/profile.png"
  copyright = "Copyright (C) 2015, Pierre Arnaud; all rights reserved."
```

Note that the `[params]` section contains parameters which are dependent
on the _selected theme_. Switching from one theme to another might require
edits in this configuration file.

## Testing out Hugo

In order to test Hugo, I created several Markdown files and put them
into `site/content/post`. Every file must start with a header which
looks like this:

```
+++
categories = ["Tools"]
date = "2015-11-17T17:19:00+01:00"
title = "Getting started with Hugo"
+++
```

It contains the metadata about the page which will enable Hugo to
do its work. Then, to see what Hugo produces, launch it in _server mode_
with an _active file system watcher_:

```cmd
hugo.exe server -w
```

Point your browser at the localhost URL and tada... You'll see your
web site, which will reload automatically whenever an edit is done.
Global setting changes won't be tracked, however.

### Using nice links

I wanted my blog posts to be organized by year and month (when looking at
their URL). Nate Finch's post
[Hugo: Beyond the Defaults](http://npf.io/2014/08/hugo-beyond-the-defaults/)
pointed me in the right direction and that's how I came to the `[permalinks]`
section in the `config.toml` file.

### Getting rid of the the Share This Buttons

The only thing I did not like about `angels-ladder`, is the way it shows
social media badges (Twitter, Facebook, Google+, etc.) and I wanted to get
rid of them. That was quite easy. Open `themes/angels-ladder/layouts/_defaults`
and edit `single.html`; just comment out the `ShareThis Buttons` section.

### Fixing JavaScript code output

The default output produced by `angels-ladder` for sections of my Markdown
tagged as JavaScript code was broken. I
[opened an issue](https://github.com/tanksuzuki/angels-ladder/issues/6)
and [Yoichi Tagaya](https://github.com/yoichitgy) kindly pointed me into
the right direction. I was not aware of
[highlight.js](https://highlightjs.org/download/) and I created a custom
package for syntax highlighting and replaced `static/js/highlight.pack.js`.

### Getting `hugo new` to work

The documentation says I should be able to create a new page simply by
executing:

```cmd
hugo.exe new post/bla.md
```

However, I got a strange error message:

> Error processing archetype ...

for which there already is an [issue](https://github.com/spf13/hugo/issues/1279).

The solution (for me) was to edit `themes/angels-ladder/archetypes/default.md`
to include a header:

```
+++
categories = [""]
+++
```

### Customizing profile image

Simply replace the profile image in `themes/angels-ladder/static/images`.
That's it.

## Building the final static content

After successfully testing my site locally, I decided to generate the public
static content and copied it over to my web server.

```cmd
hugo.exe
```

The public content is available in `site/public`.
