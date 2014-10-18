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
      karmaStart: {
        options: {
          stdout: true
        },
        command: ['cd test', '../' + NODE_DIR + '/karma/bin/karma start'].join('&&')
      },
      karmaCI: {
        options: {
          stdout: true
        },
        command: ['cd test',
              '../' + NODE_DIR +
              '/karma/bin/karma start --single-run --browsers PhantomJS'].join('&&')
      },
      buildRequireJS: {
        options: {
          stdout: false, stderr: true, failOnError: true
        },
        command: 'node ' + NODE_DIR + '/requirejs/bin/r.js -o ' + BUILD_FILE
      }
    }
  });

  grunt.registerTask('install', 'Installs dependencies.', []);
  grunt.registerTask('build', 'Build a distributable package.', ['shell:buildRequireJS']);
  grunt.registerTask('test', 'Runs tests.', ['shell:karmaStart']);
  grunt.registerTask('test:ci', 'Runs tests.', ['shell:karmaCI']);

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
