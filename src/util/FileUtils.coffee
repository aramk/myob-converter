fs = require('fs')
path = require('path')

FileUtils =
  readFixture: (filename) -> fs.readFileSync(path.join(__dirname, '..', 'fixtures', filename),
    'utf8')

module.exports = FileUtils
