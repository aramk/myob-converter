ItemCsvTransformer = require('./ItemCsvTransformer')

DataFormats =
  csv:
    name: 'CSV'
    extension: 'csv'
    itemTransformer: ItemCsvTransformer
  json:
    name: 'JSON'
    extension: 'json'

module.exports = DataFormats
