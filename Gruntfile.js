module.exports = function(grunt) {

  var path = require('path'),
      fs = require('fs');

  // Load grunt tasks automatically
  require('load-grunt-tasks')(grunt);

  var MODULE_NAME = 'myob-converter';
  var SRC_DIR = 'src';
  var BUILD_DIR = 'build';
  var NODE_DIR = 'node_modules';
  var DIST_DIR = 'dist';
  var BUILD_FILE = 'r.profile.js';

  // Define the configuration for all the tasks.
  grunt.initConfig({
    clean: {
      dist: {
        files: [
          {
            dot: true,
            cwd: DIST_DIR,
            src: [
              distPath('**', '*')
            ]
          }
        ]
      }
    },
    shell: {
    },
    mochaTest: {
      test: {
        options: {
          reporter: 'spec',
          require: 'coffee-script/register'
        },
        src: ['test/**/*Spec.coffee']
      }
    },
    'node-inspector': {
      dev: {
        options: {
          'hidden': ['node_modules']
        }
      }
    }
  });

  grunt.registerTask('install', 'Installs dependencies.', []);
  grunt.registerTask('test', 'Runs tests.', ['mochaTest']);
  grunt.registerTask('inspector', 'Runs node-inspector.', ['node-inspector:dev']);
  grunt.registerTask('test:ci', 'Runs tests.', ['mochaTest']);

  // FILES

  function readFile(file) {
    return fs.readFileSync(file, {encoding: 'utf-8'});
  }

  function writeFile(file, data) {
    if (typeof data === 'function') {
      data = data(readFile(file));
    }
    fs.writeFileSync(file, data);
  }

  function _prefixPath(dir, args) {
    var prefixedArgs = Array.prototype.slice.apply(args);
    prefixedArgs.unshift(dir);
    return path.join.apply(path, prefixedArgs);
  }

  function srcPath() {
    return _prefixPath(SRC_DIR, arguments);
  }

  function distPath() {
    return _prefixPath(DIST_DIR, arguments);
  }

  function buildPath() {
    return _prefixPath(BUILD_DIR, arguments);
  }

};
