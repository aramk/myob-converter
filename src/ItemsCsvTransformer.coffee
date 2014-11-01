fs = require('fs')
path = require('path')
Q = require('q')
_ = require('lodash')
CsvTransformer = require('./CsvTransformer')
Types = require('./util/Types')

class ItemsCsvTransformer extends CsvTransformer

  toJson: (data) ->
    # CSV can have duplicate header names, so convert to an array of values instead of an
    # object.
    @._toJson(data, {columns: null}).then (rows) => @._toJsonRows(rows)

  _toJsonRows: (rows) ->
    rowsJson = []
    header = rows.shift()
    reSubFieldParts = /^\s*-\s*([^-]+)/
    reSubHeaderParts = /^\s*([^\s-][^-]*)\s*-\s*([^\s-][^-]*)\s*$/
    getSubFieldParts = (name) -> name.match(reSubFieldParts)
    getSubFieldName = (name) -> name.replace(reSubFieldParts, '').trim()
    getSubHeaderParts = (name) -> name.match(reSubHeaderParts)
    sanitizeValue = (value) -> if !value || value.trim() == '' then null else value
    setFieldValue = (name, value, obj) ->
      obj[name.trim()] = sanitizeValue(value)
      value
    _.each rows, (row) =>
      rowJson = {}
      hasNonEmptyValue = false
      isCurrentSubField = hasNonEmptySubValue = subHeader = subFieldsBuffer = null
      resetSubFieldBuffer = ->
        isCurrentSubField = hasNonEmptySubValue = false
        subHeader = null
        subFieldsBuffer = {}
      resetSubFieldBuffer()
      addField = (name, value) ->
        if setFieldValue(name, value, rowJson)
          hasNonEmptyValue = true
      addSubField = (name, value) ->
        if setFieldValue(name, value, subFieldsBuffer)
          hasNonEmptySubValue = true
      addSubFieldBuffer = =>
        if hasNonEmptySubValue && subHeader
          @_addSubFields(subHeader, subFieldsBuffer, rowJson)
          resetSubFieldBuffer()
      _.each header, (field, i) =>
        value = row[i]
        subFieldParts = getSubFieldParts(field)
        subHeaderParts = getSubHeaderParts(field)
        if subHeaderParts
          addSubFieldBuffer()
          resetSubFieldBuffer()
          subHeader = subHeaderParts[1].trim()
          @_setUpHeaderContainer(subHeader, rowJson)
          addSubField(subHeaderParts[2], value)
        else if subFieldParts
          addSubField(subFieldParts[1], value)
        else
          addSubFieldBuffer()
          addField(field, value)
      addSubFieldBuffer()
      rowsJson.push(rowJson) if hasNonEmptyValue
    rowsJson

  _setUpHeaderContainer: (subHeader, rowJson) ->
    numberedParts = getNumberedParts(subHeader)
    if numberedParts
      prefix = numberedParts[1]
      container = rowJson[prefix] ?= []
    else
      container = rowJson[subHeader] ?= {}
    container

  _addSubFields: (subHeader, subFields, rowJson) ->
    container = @_setUpHeaderContainer(subHeader, rowJson)
    numberedParts = getNumberedParts(subHeader)
    if numberedParts
      container.push(subFields)
    else
      _.extend(container, subFields)
    container

  fromJson: (data, args) ->
    args = _.extend({
      allHeaders: true
    }, args)
    rowsCsv = []
    if args.allHeaders
      headers = CSV_FIELDS
    else
      headers = @_getCsvHeaders(data)
    headersIndexMap = {}
    _.map headers, (field, i) -> headersIndexMap[field] = i
    getOrAddRow = (rowIndex) -> rowsCsv[rowIndex] ?= []
    @_mapJsonSubFields data, (args) ->
      rowCsv = getOrAddRow(args.rowIndex)
      fieldIndex = headersIndexMap[args.csvField]
      unless fieldIndex?
        throw new Error('Cannot find header index for field ' + args.csvField)
      rowCsv[fieldIndex] = args.value
    # Add headers last, since rowIndex starts from 0.
    rowsCsv.unshift(headers)
    @_fromJson(rowsCsv)

  _mapJsonSubFields: (data, callback) ->
    _.each data, (row, rowIndex) =>
      _.each row, (value, field) =>
        context = {fields: [field], rowIndex: rowIndex, row: row}
        if Types.isArray(value)
          _.each value, (valuesArray, i) =>
            @_addSubFieldHeaders field, valuesArray, callback, context,
              (field, firstSubField) -> field + ' ' + (i + 1) + ' - ' + firstSubField
        else if Types.isObjectLiteral(value)
          @_addSubFieldHeaders(field, value, callback, context)
        else
          callback(_.extend(context, {csvField: field, value: value}))

  _addSubFieldHeaders: (headerField, subFields, callback, context, getHeaderFieldId) ->
    getHeaderFieldId ?= (field, firstSubField) -> headerField + ' - ' + firstSubField
    subFieldKeys = Object.keys(subFields)
    firstSubField = subFieldKeys.shift()
    headerContext = _.extend(context, {
      csvField: getHeaderFieldId(headerField, firstSubField),
      value: subFields[firstSubField]
    })
    headerContext.fields.push(firstSubField)
    callback(headerContext)
    _.each subFieldKeys, (subField) ->
      subValue = subFields[subField]
      callback(_.extend(context, {csvField: CSV_SUBFIELD_PREFIX + subField, value: subValue}))

  _getCsvHeaders: (data) ->
    headers = []
    headersMap = {}
    addHeader = (field) ->
      return if headersMap[field]?
      # NOTE: Some subfields will be repeated for numbered subheadings, so headersMap will be
      # useless for these.
      headersMap[field] = headers.length
      headers.push(field)
    @_mapJsonSubFields data, (args) -> addHeader(args.csvField)
    headers

####################################################################################################
# AUXILIARY
####################################################################################################

CSV_FIELDS = JSON.parse(fs.readFileSync(path.join(__dirname, 'fixtures', 'ItemFields.json')))

module.exports = ItemsCsvTransformer
