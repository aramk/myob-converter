Q = require('q')
_ = require('underscore')
CsvTransformer = require('./CsvTransformer')
Types = require('./util/Types')

class CustomersCsvTransformer extends CsvTransformer

  toJson: (data) ->
    # Customers CSV has duplicate header names, so convert to an array of values instead of an
    # object.
    @._toJson(data, {columns: null}).then (rows) => @._toCustomersJson(rows)

  _toCustomersJson: (rows) ->
    rowsJson = []
    header = rows.shift()
    reSubFieldParts = /^\s*-\s*([^-]+)/
    reSubHeaderParts = /^\s*([^-]+)-([^-]+)\s*$/
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
      _.each header, (field, i) =>
        # If the current field is the first sub field, we must add it to the header
        # (previous field).
        subFieldParts = getSubFieldParts(field)
        lastIndex = i - 1
        if i > 0 && subFieldParts
          if !isCurrentSubField
            isCurrentSubField = true
            subHeaderParts = getSubHeaderParts(header[lastIndex])
            subHeader = subHeaderParts[1].trim()
            addSubField(subHeaderParts[2], row[lastIndex])
          value = row[i]
          addSubField(subFieldParts[1], row[i])
        else if isCurrentSubField
          # Ensure all subheadings are present.
          @_setUpHeaderContainer(subHeader, rowJson)
          @_addSubFields(subHeader, subFieldsBuffer, rowJson) if hasNonEmptySubValue
          resetSubFieldBuffer()
        else if i > 0
          # Add field and value from previous index. If we are at the last index, include that as
          # well.
          addField(header[lastIndex], row[lastIndex])
          addField(field, row[i]) if i == header.length - 1
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

  fromJson: (data) ->
    rowsCsv = []
    headers = @_getCsvHeaders(data)
    headersIndexMap = {}
    _.map headers, (field, i) -> headersIndexMap[field] = i

    getOrAddRow = (rowIndex) -> rowsCsv[rowIndex] ?= []
    @_mapJsonSubFields data, (args) ->
      rowCsv = getOrAddRow(args.rowIndex)
      fieldIndex = headersIndexMap[args.csvField]
      # console.log 'args', fieldIndex, args.value, rowCsv
      return unless fieldIndex?
      rowCsv[fieldIndex] = args.value
      # console.log 'rowCsv', rowCsv
      # console.log rowCsv

    # Add headers last, since rowIndex starts from 0.
    rowsCsv.unshift(headers)

    @_fromJson(rowsCsv)

    # headersMap = {}
    # _.each headers, (field, i) ->
    #   headersMap[field] = i
    # rowsCsv.push(headers)
    # addFieldValue = (field, value, rowCsv) ->
    #   index = headersMap[field]
    #   return unless index?
    #   rowCsv[index] = value

    # _.each data, (rowJson) ->
    #   rowCsv = []
    #   rowsCsv.push(rowCsv)
    #   _.each rowJson, (value, field) ->
    #     if Types.isArray(value)
    #       console.log 'skip'
    #     else if Types.isObjectLiteral(value)
    #       # Treat inner objects as sub-fields.
    #       # TODO(aramk) Use hasSubFieldValues. See if we can reuse the logic for getting headers.
    #       if value.length == 0
    #         # Ignore subfields without any fields.
    #         return
    #       # TODO(aramk) Relies on order in object properties.
    #       subFields = Object.keys(value)
    #       firstSubField = subFields.shift()
    #       subHeader = field + ' - ' + firstSubField
    #       addFieldValue(subHeader, value[firstSubField], rowCsv)
    #       _.each subFields, (subField) ->
    #         # TODO(aramk) Add correct number of leading spaces.
    #         addFieldValue(CSV_SUBFIELD_PREFIX + subField, value[subField], rowCsv)
    #     else
    #       addFieldValue(field, value, rowCsv)
    #
    # console.log rowsCsv
    # rowsCsv

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
    firstSubField = Object.keys(subFields)[0]
    headerContext = _.extend(context, {
      csvField: getHeaderFieldId(headerField, firstSubField),
      value: subFields[firstSubField]
    })
    headerContext.fields.push(firstSubField)
    callback(headerContext)
    delete subFields[firstSubField]
    _.each subFields, (subValue, subField) ->
      callback(_.extend(context, {csvField: CSV_SUBFIELD_PREFIX + subField, value: subValue}))

  _getCsvHeaders: (data) ->
    headers = []
    headersMap = {}
    addHeader = (field) ->
      # NOTE: Some subfields will be repeated for numbered subheadings, so headersMap will be
      # useless for these.
      headersMap[field] = headers.length
      headers.push(field)
    @_mapJsonSubFields data, (args) -> addHeader(args.csvField)
    headers

####################################################################################################
# AUXILIARY
####################################################################################################

# NOTE: This contains tabs and spaces.
CSV_SUBFIELD_PREFIX = "           - "
getNumberedParts = (name) -> name.match(/^(\w+)\s+(\d+)\s*$/)
# Adds the given value to the given array if it is not undefined or an empty string. If an object is
# also provided, it is used in place of the value.
pushIfDefined = (value, array, obj) ->
  if value && value.trim().length > 0
    array.push(if obj != undefined then obj else value)

module.exports = CustomersCsvTransformer