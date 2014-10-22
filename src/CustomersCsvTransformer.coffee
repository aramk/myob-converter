Q = require('q')
_ = require('underscore')
CsvTransformer = require('./CsvTransformer')

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
          @_addSubFields(subHeader, subFieldsBuffer, rowJson) if hasNonEmptySubValue
          resetSubFieldBuffer()
        else if i > 0
          addField(header[lastIndex], row[lastIndex])
        else if i == rows.length - 1
          addField(field, row[i])
      rowsJson.push(rowJson) if hasNonEmptyValue
    rowsJson

  _addSubFields: (subHeader, subFields, rowJson) ->
    # isNumberedField = (name) -> /\d+\s*$/.test(name)
    getNumberedParts = (name) -> name.match(/^(\w+)\s+(\d+)\s*$/)
    numberedParts = getNumberedParts(subHeader)
    if numberedParts
      prefix = numberedParts[1]
      container = rowJson[prefix] ?= []
      container.push(subFields)
    else
      container = rowJson[subHeader] ?= {}    
    container

# Adds the given value to the given array if it is not undefined or an empty string. If an object is
# also provided, it is used in place of the value.
pushIfDefined = (value, array, obj) ->
  if value && value.trim().length > 0
    array.push(if obj != undefined then obj else value)

module.exports = CustomersCsvTransformer
