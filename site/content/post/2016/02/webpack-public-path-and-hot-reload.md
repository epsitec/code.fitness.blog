+++
categories = [""]
date = "2016-02-03T18:12:59+01:00"
title = "Webpack, Hot Module Replacement and the public path"
+++

I've been digging deep into [Webpack](https://webpack.github.io/) lately.
I wanted to be able to trigger hot reloading from an external source, not
just from a running [`webpack-dev-server`](https://webpack.github.io/docs/webpack-dev-server.html)
instance.

## What does Webpack do?

Running Webpack bundles the assets (the source files) together and
produces _bundles_ which are ready for inclusion from a web page.
And for every bundle, Webpack computes a unique _hash_ based on its
content.

Peeking inside a bundle reveals that it starts with some bootstrapper
code, which defines the current hash `1deb...` (as `hotCurrentHash`):

```javascript
/******/  var hotApplyOnUpdate = true;
/******/  var hotCurrentHash = "1deb3b7f73f42347f064";
/******/  var hotCurrentModuleData = {};
/******/  var hotCurrentParents = [];
``` 

When started with the `--watch` option, Webpack does not quit after having
generated the bundle(s). It sits there, waiting for one of the source files
to change. Whenever it detectes a change, Webpack updates the bundles. If
properly configured, it will also produce incremental updates.

For instance:

```cmd
    hot/0.91f0a825e34234177742.hot-update.js   7.96 kB
    hot/91f0a825e34234177742.hot-update.json  36 bytes
hot/0.91f0a825e34234177742.hot-update.js.map   9.12 kB
```

The `.json` file is a _manifest_ which describes the incremental update,
basically linking the current set of changes (identified by hash `91f0...`)
with the previous version of the bundle:

```json
{"h":"1deb3b7f73f42347f064","c":[0]}
```

The `h` value  `1deb...` is the same as the `hotCurrentHash` of the previous
bundle. This guarantees that the **Hot Module Replacement** (HMR) mechanism
won't try to apply a set of updates to the wrong bundle version.

## The incremental update

The updated module (file `hot/0.91f0...2.hot-update.js` in my previous example)
contains the whole chunk to replace:

```javascript
webpackHotUpdate(0,{
/***/ 452:
/*!************************************************!*\
  !*** ./src/core/proxies/presentation-proxy.js ***!
  \************************************************/
/***/ function(module, exports, __webpack_require__) {
  ...
/***/ }
})
//# sourceMappingURL=0.91f0a825e34234177742.hot-update.js.map
```

In this example, the chunk (which maps to a `require` in the original source
code) has the id `452`. HMR will swap out the previous version of the chunk
for this one.

## Configuring Webpack

To properly set up HMR, add following entries in the Webpack configuration file
(see [webpack-dev-hmr](https://github.com/mattpage/webpack-dev-hmr) for a
detailed explanation):

```javascript
module.exports = {
  entry: [
    'webpack-dev-server/client?http://localhost:3000',
    'webpack/hot/only-dev-server',
    './src/app.js'
  ],
  output: {
    filename: '[name].js',
    path: output,
    publicPath: 'http://localhost:3000/',
    hotUpdateChunkFilename: 'hot/[id].[hash].hot-update.js',
    hotUpdateMainFilename: 'hot/[hash].hot-update.json'
  },
  plugins: [
    new webpack.HotModuleReplacementPlugin (),
    new webpack.NoErrorsPlugin ()
  ],
  module: {
    loaders: [
      {test: /\.js|\.jsx$/,  exclude: /node_modules/, loader: 'babel'},
    ]
  }
};
```

Webpack will include code which connect to the `webpack-dev-server` and
will listen to update notifications and automatically trigger HMR. The
URI used to load the updates will have to match `http://localhost:3000/`
as defined by the `publicPath` output setting.  

## Removing webpack-dev-server from the equation

In my case, I did not want to use Webpack's dev server, so I decided to
remove it from the configuration file:

```javascript
module.exports = {
  entry: [
    // 'webpack-dev-server/client?http://localhost:3000', <-- remove this
    'webpack/hot/only-dev-server',
    './src/app.js'
  ],
  output: {
    filename: '[name].js',
    path: output,
    // publicPath: 'http://localhost:3000/', <--------------- remove this
    hotUpdateChunkFilename: 'hot/[id].[hash].hot-update.js',
    hotUpdateMainFilename: 'hot/[hash].hot-update.json'
  },
  plugins: [
    new webpack.HotModuleReplacementPlugin (),
    new webpack.NoErrorsPlugin ()
  ],
  module: {
    loaders: [
      {test: /\.js|\.jsx$/,  exclude: /node_modules/, loader: 'babel'},
    ]
  }
};
```

## Triggering the update

Now, whenever I edit the source code while `webpack --watch` is running,
it still produces the hot updates, but the running bundle won't pick up
the changes. For that, I have to trigger HMR myself.

In my setup, the back-end is listening for changes in the `hot` folder.
When a `*.json` file gets created, it notifies the JavaScript front-end
through SignalR and sends it the hash of the update:

```javascript
webpackHotUpdate (hash) {
  trace.log ('Webpack: hot update # ' + hash); //
  window.postMessage ('webpackHotUpdate' + hash, '*');
}
```

HMR is triggered by posting a message `webpackHotUpdate91f0a...`. The
code which sets up the event handler sits in `hot/dev-server.js`:

```javascript
addEventListener ("message", function (event) {
  if (typeof event.data === "string" && event.data.indexOf ("webpackHotUpdate") === 0) {
    lastData = event.data;
    if (!upToDate () && module.hot.status () === "idle") {
      console.log ("[HMR] Checking for updates on the server...");
      check ();
    }
  }
});
```

The check itself will start the real download of every _chunk_,
reusing the _hot current hash_ to identifiy the files to be
fetched, and inserting a `<script>` node into the HTML head:

```javascript
/******/  function hotDownloadUpdateChunk (chunkId) {
/******/ 	  var head = document.getElementsByTagName ("head")[0];
/******/ 	  var script = document.createElement ("script");
/******/ 	  script.type = "text/javascript";
/******/ 	  script.charset = "utf-8";
/******/    script.src = __webpack_require__.p + "hot/" + chunkId + "." + hotCurrentHash + ".hot-update.js";
/******/    head.appendChild (script);
/******/  }
```

Note how the URI (`src` attribute) is constructed:

* `__webpack_require__.p` &rarr; the path cofigured by the `publicPath`
  setting in the Webpack configuration file.
* `"hot/"` &rarr; the subfolder for HMR files.
* `chunkId` &rarr; the _id_ of the chunk to replace (staring from zero).
* `"."` &rarr; a separator.
* `hotCurrentHash` &rarr; the hash of this version of the update.
* `".hot-update.js"` &rarr; the end of the file name.

## Overriding the public path

In the standard HMR approach where `webpack-dev-server` is serving the
updates, the URI used by HMR is hardcoded in the Webpack configuration
file (`publicPath`).

I wanted to serve my updates from a different URI, which would only be
known at run time. The [documentation](https://webpack.github.io/docs/configuration.html#output-publicpath)
explains how you can override the public path by setting the variable
`__webpack_public_path__` dynamically at runtime (see also
[this discussion](https://github.com/webpack/webpack/issues/443)). 

But it does not work with HMR. It took me the good part of an afternoon
to find out that **Hot module replacement is not compatible** with
`__webpack_public_path__` (it is a [known issue](https://github.com/webpack/webpack/issues/1650)
of HMR).

After banging my head against `publicPath` and `__webpack_public_path__`
I finally decided to rely on the default HMR behavior. When no public
path has been set, `__webpack_require__.p` will equal to `""` and the
updates will be fetched from the same origin as the other assets.

Knowing that, I updated my Nancy web server to simply ship the hot
updates from the default `http://host:port/hot/...` URI.

> **[EDIT]** The issues have been addressed by Tobias Koppers. It is
> now possible to use `__webpack_public_path__` with HMR too. Thanks
> a lot for the quick fixes.
