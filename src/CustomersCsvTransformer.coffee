fs = require('fs')
path = require('path')
FileUtils = require('./util/FileUtils')
MyobCsvTransformer = require('./MyobCsvTransformer')

class CustomersCsvTransformer extends MyobCsvTransformer

  _getAllCsvHeaders: -> JSON.parse(FileUtils.readFixture('CustomerFields.json'))

module.exports = CustomersCsvTransformer
