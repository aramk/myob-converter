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
          addField(header[lastIndex], row[lastIndex])
        else if i == rows.length - 1
          addField(field, row[i])
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
    headers = @_getJsonHeaders(data)
    \ test this out and use _mapSubFields instead.
    console.log headers
    return ''

    headersMap = {}
    _.each headers, (field, i) ->
      headersMap[field] = i
    rowsCsv.push(headers)
    addFieldValue = (field, value, rowCsv) ->
      index = headersMap[field]
      return unless index?
      rowCsv[index] = value

    _.each data, (rowJson) ->
      rowCsv = []
      rowsCsv.push(rowCsv)
      _.each rowJson, (value, field) ->
        if Types.isArray(value)
          console.log 'skip'
        else if Types.isObjectLiteral(value)
          # Treat inner objects as sub-fields.
          # TODO(aramk) Use hasSubFieldValues. See if we can reuse the logic for getting headers.
          if value.length == 0
            # Ignore subfields without any fields.
            return
          # TODO(aramk) Relies on order in object properties.
          subFields = Object.keys(value)
          firstSubField = subFields.shift()
          subHeader = field + ' - ' + firstSubField
          addFieldValue(subHeader, value[firstSubField], rowCsv)
          _.each subFields, (subField) ->
            # TODO(aramk) Add correct number of leading spaces.
            addFieldValue(CSV_SUBFIELD_PREFIX + subField, value[subField], rowCsv)
        else
          addFieldValue(field, value, rowCsv)
    # console.log headers
    console.log rowsCsv
    rowsCsv

  _mapSubFields: (data, callback) ->
    # headers = []
    # headersMap = {}
    # addHeader = (field) ->
    #   # NOTE: Some subfields will be repeated for numbered subheadings, so headersMap will be useless for these.
    #   # headersMap[field] = headers.length
    #   headers.push(field)
    _.each data, (row) ->
      _.each row, (value, field) ->
        # if headersMap[field] != undefined
        #   return
        if value
          hasSubFieldValues = false
          if Types.isArray(value)
            # If no items exist in this subfield, search for the first one in all rows. This will only occur once
            # for this subheader.
            subFields = value[0]
            hasSubFieldValues = !!subFields
          else if Types.isObjectLiteral(value)
            subFields = value
            hasSubFieldValues = Object.keys(subFields).length > 0
          else
            return
          unless hasSubFieldValues
            _.find data, (otherRow) ->
              return if row == otherRow
              subFields = otherRow[field]
              return subFields != undefined && subFields.length > 0
          # If no subfields are found for this subheading, ignore it.
          return unless subFields
          firstSubField = Object.keys(subFields)[0]
          callback(field + ' - ' + firstSubField)
          delete subFields[firstSubField]
          _.each subFields, (subValue, subField) ->
            callback(CSV_SUBFIELD_PREFIX + subField)
        else
          callback(field)
    # headers

  _getJsonHeaders: (data) ->
    headers = []
    headersMap = {}
    addHeader = (field) ->
      # NOTE: Some subfields will be repeated for numbered subheadings, so headersMap will be useless for these.
      headersMap[field] = headers.length
      headers.push(field)
    @_mapSubFields data, addHeader
    # _.each data, (row) ->
    #   _.each row, (value, field) ->
    #     if headersMap[field] != undefined
    #       return
    #     if value
    #       hasSubFieldValues = false
    #       if Types.isArray(value)
    #         # If no items exist in this subfield, search for the first one in all rows. This will only occur once
    #         # for this subheader.
    #         subFields = value[0]
    #         hasSubFieldValues = !!subFields
    #       else if Types.isObjectLiteral(value)
    #         subFields = value
    #         hasSubFieldValues = Object.keys(subFields).length > 0
    #       else
    #         return
    #       unless hasSubFieldValues
    #         _.find data, (otherRow) ->
    #           return if row == otherRow
    #           subFields = otherRow[field]
    #           return subFields != undefined && subFields.length > 0
    #       # If no subfields are found for this subheading, ignore it.
    #       return unless subFields
    #       firstSubField = Object.keys(subFields)[0]
    #       addHeader(field + ' - ' + firstSubField)
    #       delete subFields[firstSubField]
    #       _.each subFields, (subValue, subField) ->
    #         addHeader(CSV_SUBFIELD_PREFIX + subField)
    #     else
    #       addHeader(field)
    headers

CSV_SUBFIELD_PREFIX = '           - '
getNumberedParts = (name) -> name.match(/^(\w+)\s+(\d+)\s*$/)
# Adds the given value to the given array if it is not undefined or an empty string. If an object is
# also provided, it is used in place of the value.
pushIfDefined = (value, array, obj) ->
  if value && value.trim().length > 0
    array.push(if obj != undefined then obj else value)

module.exports = CustomersCsvTransformer
