+++
categories = ["js"]
date = "2015-11-17T10:24:00+01:00"
title = "NPM and peer dependencies"
+++

While working on the [`mai-chai` module](https://github.com/epsitec-sa/mai-chai)
I realized that I should be using
[`peerDependencies`](https://nodejs.org/en/blog/npm/peer-dependencies/).

The `mai-chain` module expects that its consumer installs `chai`, but it
does not really depend on it. This `package.json` excerpt:

```json
"devDependencies": {
},
"dependencies": {
  "chai": "^3.4.1",
  "chai-equal-jsx": "^1.0.2",
  "chai-spies": "^0.7.1",
  "chai-string": "^1.1.3",
  "dirty-chai": "^1.2.2"
}
```

has to be replaced with the following:

```json
"devDependencies": {
},
"dependencies": {
  "chai-equal-jsx": "^1.0.2",
  "chai-spies": "^0.7.1",
  "chai-string": "^1.1.3",
  "dirty-chai": "^1.2.2"
},
"peerDependencies": {
  "chai": "^3.4.1"
}
```

Note that the reference to `chai` was moved from `dependencies`
to `peerDependencies`.
