fs = require('fs')
path = require('path')
FileUtils = require('./util/FileUtils')
MyobCsvTransformer = require('./MyobCsvTransformer')

class JobsCsvTransformer extends MyobCsvTransformer

  _getAllCsvHeaders: -> JSON.parse(FileUtils.readFixture('JobFields.json'))

module.exports = JobsCsvTransformer
