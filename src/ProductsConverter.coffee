class ProductsConverter extends MyobConverter

  constructor: ->


# Exports
if typeof module != 'undefined'
  module.exports =
    converter: MyobConverter
else if typeof window != 'undefined'
  window.MyobConverter = MyobConverter
