CsvTransformer = require('./CsvTransformer')

DataFormats =
  csv:
    name: 'CSV'
    extension: 'csv'
    transformer: CsvTransformer
  json:
    name: 'JSON'
    extension: 'json'

module.exports = DataFormats
