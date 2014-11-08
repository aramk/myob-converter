fs = require('fs')
path = require('path')
FileUtils = require('./util/FileUtils')
MyobCsvTransformer = require('./MyobCsvTransformer')

class ItemsCsvTransformer extends MyobCsvTransformer

  _getAllCsvHeaders: -> JSON.parse(FileUtils.readFixture('ItemFields.json'))

module.exports = ItemsCsvTransformer
