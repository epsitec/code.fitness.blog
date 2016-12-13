+++
categories = ["js", "tools"]
date = "2016-02-25T17:47:20+01:00"
title = "Tired of setting up JavaScript environments?"
+++

The last couple of weeks, I have been working on multiple NPM
packages. And for every package I had to copy various files I
need so that the linters and the editor behave as I expect:

* `.editorconfig` &rarr; UTF-8, indent style and site, etc.
* `.gitattributes` &rarr; so that `package.json` stays with LF.
* `.jscrc` &rarr; settings for JSCS.
* `.jshintrc` &rarr; settings for JSHINT.
* `.babelrc` &rarr; settings for Babel.

I have now over a dozen of these projects, which should all share
the same files. And changing one single setting requires manually
copying them over to all other projects, which is tedious.

## npm to the rescue

At first, I hoped I could use git to somehow share the files, e.g.
as using _submodules_. This did not work, as I need to deploy
all these files in the root, and I could not find a means to
do this with git submodules.

Then I figured that I could create an npm package which, when
installed, would copy template files to the project root. And
that's how [generic-js-env](https://github.com/epsitec-sa/generic-js-env)
and [babel-env](https://github.com/epsitec-sa/babel-env) got
born.

In the `postinstall` step of these packages, I start a small
JavaScript program which figures out what path to use for the
root folder, then simply enumerates all files found in the
`template` folder and copies them all to the root, possibly
overwriting already existing files.

## Show me the code

Here is the script that gets executed when you install the
`generic-js-env` package (such as running `npm install --save-dev
generic-js-env`):

```javascript
var cwd = process.cwd ().replace (/\\/g, '/');
var suffix = '/node_modules/generic-js-env';

if (cwd.endsWith (suffix)) {
  var root = cwd.substr (0, cwd.length - suffix.length);
  var files = fs.readdirSync (path.join (cwd, 'templates'));
  files.forEach (function (file) {
    var data = fs.readFileSync (path.join (cwd, 'templates', file));
    fs.writeFileSync (path.join (root, file), data);
  });
}
```
  
I did not find another way to locate the root folder, so I
decided to start from the current working directory (that's
the root of the installed node module) and move up two levels.

Obviously, the `generic-js-env` and `babel-env` packages are
tailored for my own needs, and they most certainly won't match
your settings. So feel free to fork the repos and produce your
own versions.
