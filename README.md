SubDiv.js
======

[![Build Status](https://travis-ci.org/Urbanetic/subdiv.svg?branch=develop)](https://travis-ci.org/Urbanetic/subdiv)

Polygon Subdivision in JavaScript. The use case in mind is subdividing urban city blocks into individual lots containing a single building.

![image](demo/images/concave.png)

## Installation

To install all the dependences for building and testing the library:

```
npm install
grunt install
```

## Usage

See `demo/demo.html` for a visual demo.

### NodeJS

Currently you need the `requirejs` package, but using [amdefine](https://github.com/jrburke/amdefine) could be an option.

```
node demo/demo-nodejs.js
```

## Building

To build a distributable package in `dist/subdiv.js`:

```
grunt build
```

## Tests

To run Karma tests in Chrome:

```
grunt test
```

To run karma manually:

```
cd test
karma start --browsers <BrowserName>
```

## References

* [Algorithm Design Document](https://docs.google.com/document/d/1VJckB6UciabRqYcAxP6ge-qr1Z3dHMhNuYebafPjdV0/edit)
* [Task Tracker](https://trello.com/b/tAI02CcG/subdiv)

## License

Released under the MIT License.
