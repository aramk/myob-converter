var tests = [],
// TODO(aramk) Uncomment when committing.
    specsConfig = [
        'MyobConverter'
    ];

specsConfig.forEach(function(name) {
  tests.push('/base/test/specs/' + name + 'Spec.coffee');
});

// Shims for PhantomJS

var isFunction = function(o) {
  return typeof o == 'function';
};

var bind,
    slice = [].slice,
    proto = Function.prototype,
    featureMap;

featureMap = {
  'function-bind': 'bind'
};

function has(feature) {
  var prop = featureMap[feature];
  return isFunction(proto[prop]);
}

// check for missing features
if (!has('function-bind')) {
  // adapted from Mozilla Developer Network example at
  // https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Function/bind
  bind = function bind(obj) {
    var args = slice.call(arguments, 1),
        self = this,
        nop = function() {
        },
        bound = function() {
          return self.apply(this instanceof nop ? this : (obj || {}),
              args.concat(slice.call(arguments)));
        };
    nop.prototype = this.prototype || {}; // Firefox cries sometimes if prototype is undefined
    bound.prototype = new nop();
    return bound;
  };
  proto.bind = bind;
}

// End shims for PhantomJS

window.__karma__.start();

requirejs.config({
  // Karma serves files from '/base'.
  baseUrl: '/base',

  packages: [
    {name: 'underscore', location: 'lib', main: 'underscore.js'}
  ],

  // Ask requirejs to load these files.
  deps: tests,

  // Start tests running once requirejs is done.
  callback: window.__karma__.start
});
