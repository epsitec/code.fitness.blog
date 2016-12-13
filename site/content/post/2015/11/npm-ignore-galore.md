+++
categories = ["build"]
date = "2015-11-25T09:24:03+01:00"
title = "The .npmignore galore"
+++

In project [`electrum`](https://github.com/epsitec-sa/electrum), we need
to ship not only the ES2015 source code, but also its transpiled version.

The way to go is to add a `compile` and a `prebuild` step for npm:

```json
"scripts": {
  "compile": "babel -d lib/ src/",
  "prepublish": "npm run compile"
},
```

* The `compile` step invokes Babel and outputs the transpiled files found
  in folder `src` to folder `lib`. Invoking the `compile` step is done with
  `npm run compile`.
* The `prepublish` step launches `compile`. It will be automatically started
  as a result of doing an `npm publish`.

In order for the consumers of the `electrum` package to get the transpiled
version of the code, the `main` property must be updated to point to `lib`:

```json
"main": "lib/index.js"
```

I also modified my `.gitignore` file to exclude `lib` from being part of the
git repository.

```cmd
lib/
```

Having done that, I published an updated version of `electrum` using:

```cmd
npm publish
```

...and voilà, here it is: https://www.npmjs.com/package/electrum

## So `npm install` - where's my lib?

Trying to consume the new `electrum` package did not succeed. I kept
getting error messages from WebPack:

> Module not found: Error: Cannot resolve module 'electrum' in S:\\git\\foo\\bar

Why? Because `node_modules/electrum` does not contain a `lib`
folder and `lib/index.js` cannot be found.

Here is the folder structure (use `npm install electrum@1.1.2`
if you want to have a look at the misbehaving package):

```cmd
src
test
.babelrc
.npmignore
...
```

Do you see that `.npmignore` file? I did not define any in my package
source, but there it is. And it contains:

```cmd
lib/
node_modules/
```

This `.npmignore` is being synthesized by npm when running `npm publish`.

## Why does `lib/` get ignored?

Here is what the [documentation](https://docs.npmjs.com/misc/developers#keeping-files-out-of-your-package)
says about `.npmignore`:

> Use a `.npmignore` file to keep stuff out of your package. If there's no
> `.npmignore` file, but there is a `.gitignore` file, then npm will ignore
> the stuff matched by the `.gitignore` file.

So npm is trying to be smart here: it sees that I don't want `lib/` to get
included in my git repository, and it assumes that I don't want it to be
included it in the resulting package either.

The solution is simple:

> If you want to include something that is excluded by your `.gitignore`
> file, you can create an empty `.npmignore` file to override it.

Version [1.1.4](https://github.com/epsitec-sa/electrum/releases/tag/v1.1.4)
of the Electrum package finally got it right...
