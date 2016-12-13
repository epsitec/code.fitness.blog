+++
categories = ["build"]
date = "2015-11-30T17:33:16+01:00"
title = "Require self as an npm module"
+++

While working in [electrum-arc](https://github.com/epsitec-sa/electrum-arc/),
I wanted to be able to require components defined in `electrum-arc` itself,
without having to use a relative path.

I don't want to _think_ about my code layout while I am coding. The
simple fact of having to add `..` in the path when importing another
component from a source file is a disruption in my thought process:

```javascript
import Button from '../../buttons/Button.js';
``` 

I'd rather be able to consume my own components just like the end
user of `electrum-arc`, simply by doing:

```javascript
import {Button} from 'electrum-arc';
```

# require-self to the rescue

The easiest solution I have found is to use [`require-self`](https://www.npmjs.com/package/require-self)
which addresses exactly that issue. Details can be found on the
[npm page](https://github.com/epsitec-sa/electrum-arc/).

To use `require-self`, here is all I did:

1. In the `compile` step, add a call to `require-self`.
2. Add a reference to it under the `devDependencies`.
3. Execute (at least once) `npm run compile` so that the magic
   of `require-self` can be put in place.

The last step is not needed if `compile` gets called by `npm prepublish`,
because the simple fact of executing an `npm install require-self --save-dev`
will trigger a `prepublish` and thus execute `require-self`. 
   
# Example

Here is an example taken from `electrum-arc`'s `package.json`:

```json
"scripts": {
  "compile": "rimraf ./lib && require-self && npm run regen && babel -d lib src"
  "regen": "electrum-require-components --wrap ./src components .component.js all-components.js",
  "prepublish": "npm run compile"
},
"devDependencies": {
  ...
  "electrum-require-components": "^0.2.1",
  "require-self": "^0.1.0",
  "rimraf": "^2.4.4",
  ...
}
```

# How does it work?

I don't like magic. So let's see how `require-self` works under the
cover. After executing `require-self`, a new file will be written
under `node_modules`, called `electrum-arc.js`, which contains the
bare minimum to export the full module:

```javascript
module.exports = require ('..');
```

And since '..' happens to be the root of the module, the `require`
conventions will map that to importing my `electrum-arc` module
itself.

# And what's that rimraf?

You'll have noticed that my `compile` step consists in several
distinct commands:

1. `rimraf ./lib` &rarr; portable `rm -rf` of the `lib` folder.
2. `require-self` &rarr; set up the require self magic.
3. `npm run regen` &rarr; regenerate source code (see my post on
[electrum-require-components](building-electrum-require-components-tool.html)
for the details).
4. `babel -d lib/ src/` &rarr; produce ES5 code.

So `rimraf` is just a portable version of `rm -rf` which is
implemented yet another node module. 
