path = require('path')
fs = require('fs')
DataFormats = require('./DataFormats')

class MyobConverter

  constructor: ->

  convert: (data, fromFormatId, toFormatId) ->
    if fromFormatId == toFormatId
      return data
    else if !DataFormats[fromFormatId]
      throw new Error('fromFormatId ' +  + ' not supported.')
    else if !DataFormats[toFormatId]
      throw new Error('toFormatId ' + toFormatId + ' not supported.')
    if fromFormatId == 'json'
      throw new Error('Cannot convert from JSON - it is the intermediate format.')
    if typeof data == 'string'
      data = JSON.parse(data)
    fromDataFormat = DataFormats[fromFormatId]
    fromTransformer = new fromFormat.transformerClass()
    json = fromTransformer.toJson(data)
    if toFormatId == 'json'
      return json
    toTransformer = new toFormatId.transformerClass()
    toTransformer.fromJson(json)

  convertPath: (filePath, toFormatId) ->
    extension = path.extname(filePath)
    fromFormatId = null
    fromFormatId = _.find DataFormats, (format, id) ->
      if format.extension == extension
        fromFormatId = id
        true
    unless fromFormatId
      throw new Error('fromFormat ' + fromFormatId + ' not supported.')
    data = fs.readFileSync(filePath, 'utf8')
    @convert(data, fromFormatId, toFormatId)

# Exports
module.exports = MyobConverter
