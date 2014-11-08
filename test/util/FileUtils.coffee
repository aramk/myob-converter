fs = require('fs')
path = require('path')

# TODO(aramk) Refactor to use the version in src/util.

FileUtils =
  readFixture: (filename) -> fs.readFileSync(path.join(__dirname, '..', 'fixtures', filename),
    'utf8')

module.exports = FileUtils
