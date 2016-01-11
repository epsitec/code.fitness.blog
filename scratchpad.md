# Resources
## JavaScript
### Tips

Why you should not slice `arguments`:

* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/arguments
* https://github.com/petkaantonov/bluebird/wiki/Optimization-killers#32-leaking-arguments

How to identify a class as a class:

* http://stackoverflow.com/questions/29093396/how-do-you-check-the-difference-between-an-ecmascript-6-class-and-function
* See electrum, src/utils/checks.js

## React
### Testing

* http://reactkungfu.com/2015/07/approaches-to-testing-react-components-an-overview/
* http://jaketrent.com/post/testing-react-with-jsdom/

## GitHub
### Badges

* Example of npm and build badges: https://github.com/omniscientjs/omniscient

## Tools

* Use `npm-check` rather than `npm outdated`.

# Various
## Computers
### Upgrading an iMac

* Disable System Integrated Protection (SIP) with `csrutil disable`
  to modify the MBR and partition info with the Disk Utility, when
  getting `could not change the partition type` while trying to
  restore the bootcamp partition.
  http://twocanoes.com/products/mac/winclone
  http://apple.stackexchange.com/questions/208478/how-do-i-disable-system-integrity-protection-sip-aka-rootless-on-os-x-10-11
  
* Replace HDD with an SSD
  https://www.ifixit.com/Guide/iMac+Intel+21.5-Inch+EMC+2308+Hard+Drive+Replacement/1766
  http://exirion.net/ssdfanctrl/
  http://www.applecomponents.com/computers/imac-27-inch-mid-2010/
  
# Design
##Material Design for Bootstrap

* http://mdbootstrap.com/

https://github.com/babel/babel/blob/master/packages/babel-plugin-transform-es2015-modules-commonjs/src/index.js
line 32, buildExportAll

let buildExportAll = template(`
  for (let KEY in OBJECT) {
    if (KEY === "default") continue;

    Object.defineProperty(exports, KEY, {
      enumerable: true,
      get: function () {
        return OBJECT[KEY];
      }
    });
  }
`);


export * from './all-components.js';

--->

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _allComponents = require('./all-components.js');

var _loop = function _loop(_key2) {
  if (_key2 === "default") return 'continue';
  Object.defineProperty(exports, _key2, {
    enumerable: true,
    get: function get() {
      return _allComponents[_key2];
    }
  });
};

for (var _key2 in _allComponents) {
  var _ret = _loop(_key2);

  if (_ret === 'continue') continue;
}

---- previously...

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _allComponents = require('./all-components.js');

for (var _key in _allComponents) {
  if (_key === "default") continue;
  Object.defineProperty(exports, _key, {
    enumerable: true,
    get: function get() {
      return _allComponents[_key];
    }
  });
}
