+++
categories = ["JavaScript"]
date = "2016-03-15T09:34:31+01:00"
title = "My JavaScript testing environment"
+++

In [Tired of setting up JavaScript environments?](/post/2016/02/setting-up-javascript-environments.html)
I explained how I use `npm` to configure a working environment, where
all Babel and editor related configuration files are automatically
created with my defaults.

I decided to go a step further and updated project
[mai-chai](https://github.com/epsitec-sa/mai-chai) to version 2.

Now, adding `mai-chai` to a project with:

```cmd
npm install --save-dev mai-chai
```

automatically includes `mocha` and `chai`.

It also creates a `./test` folder with `mocha.opts` and the
`test-helper.js` helper file (which gets required automatically
into every test file), so that `window` and `document` globals
are available in the test environment.

# My good friend Wallaby

I am also using [Wallaby.js](http://wallabyjs.com/) extensively
from both the **atom** and the **Visual Studio Code** editors.
Wallaby.js needs a configuration file which describes where the
source is located, what should be run as tests and some gory
startup code needed to work well with `React` and with
`require-self`.

Since v2 of mai-chai, a preconfigured `wallaby.conf.js` file 
is automatically copied to the root of the project. For this
to work, the project has to adhere to the following conventions:

* `./src` contains the source code of the project.
* `./src.test` contains the tests for the project.
* `./test` contains the configuration for `mocha`.

Artifacts get compiled by Babel and copied to `./lib` (for
the source) and `./lib.test` (for the tests).

# Starting a new project

My process for creating a new project now looks like this:

```cmd
cd foo
npm init
npm install --save-dev generic-js-env babel-env mai-chai
```

To see a basic example of such a project, where I have added
manually:

* `.gitignore`
* `./src/index.js`
* `./src.test/index.js`

can be found [here](https://github.com/epsitec-sa/mai-chai-test/tree/master).
