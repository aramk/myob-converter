fs = require('fs')
path = require('path')
_ = require('lodash')

FileUtils = require('./util/FileUtils')
MyobCsvTransformer = require('./MyobCsvTransformer')

class ItemSalesCsvTransformer extends MyobCsvTransformer

  toJson: (data) -> super(data).then(@_toItemSalesJson)

  _toItemSalesJson: (data) ->
    # Each row is a product and quantity and part of an invoice, which can span multiple rows.
    # Combine these such that each row is a unique invoice with the product quantity information.
    invoiceRows = []
    currentInvoiceId = null
    currentInvoiceRow = null
    
    addCurrentInvoiceRow = -> invoiceRows.push(currentInvoiceRow)
    setUpCurrentInvoiceRow = (row) ->
      currentInvoiceRow = row = _.extend({}, row)
      row[ITEMS_FIELD] = []
      addInvoiceItems(row)
      _.each ITEM_FIELDS, (field) -> delete row[field]

    addInvoiceItems = (row) ->
      props = _.pick(row, ITEM_FIELDS)
      currentInvoiceRow[ITEMS_FIELD].push(props)

    _.each data, (row) ->
      invoiceId = row[INVOICE_ID_FIELD]
      newInvoiceRow = invoiceId != currentInvoiceId
      if newInvoiceRow
        addCurrentInvoiceRow() if currentInvoiceRow
        setUpCurrentInvoiceRow(row)
        currentInvoiceId = invoiceId
      else
        addInvoiceItems(row)
    
    addCurrentInvoiceRow() if currentInvoiceRow
    return invoiceRows

  fromJson: (data, args) ->
    rows = @_fromItemSalesJson(data)
    super(rows, args)

  _fromItemSalesJson: (data) ->
    rows = []
    _.each data, (invoiceRow) ->
      items = invoiceRow[ITEMS_FIELD]
      _.each items, (item) ->
        row = _.extend({}, invoiceRow, item)
        delete row[ITEMS_FIELD]
        rows.push(row)
      rows.push({})
    rows

  _getAllCsvHeaders: -> JSON.parse(FileUtils.readFixture('ItemSaleFields.json'))

####################################################################################################
# AUXILIARY
####################################################################################################

INVOICE_ID_FIELD = 'Invoice #'
ITEMS_FIELD = 'Items'
ITEM_FIELDS = JSON.parse(FileUtils.readFixture('ItemSaleItemFields.json'))

module.exports = ItemSalesCsvTransformer
