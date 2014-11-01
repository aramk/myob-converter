fs = require('fs')
path = require('path')
MyobCsvTransformer = require('./MyobCsvTransformer')

class ItemsCsvTransformer extends MyobCsvTransformer

  _getAllCsvHeaders: ->
    JSON.parse(fs.readFileSync(path.join(__dirname, 'fixtures', 'ItemFields.json')))

module.exports = ItemsCsvTransformer
