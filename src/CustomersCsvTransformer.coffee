fs = require('fs')
path = require('path')
MyobCsvTransformer = require('./MyobCsvTransformer')

class CustomersCsvTransformer extends MyobCsvTransformer

  _getAllCsvHeaders: ->
    JSON.parse(fs.readFileSync(path.join(__dirname, 'fixtures', 'CustomerFields.json')))

module.exports = CustomersCsvTransformer
