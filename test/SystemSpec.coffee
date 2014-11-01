expect = require('chai').expect
myob = require('../src')
MyobConverter = require('../src/MyobConverter')
CsvTransformer = require('../src/CsvTransformer')
MyobCsvTransformer = require('../src/MyobCsvTransformer')
CustomersCsvTransformer = require('../src/CustomersCsvTransformer')
ItemsCsvTransformer = require('../src/ItemsCsvTransformer')

describe 'The library', ->

  it 'can be required', ->
    expect(myob.MyobConverter).to.equal(MyobConverter)
    expect(myob.CsvTransformer).to.equal(CsvTransformer)
    expect(myob.MyobCsvTransformer).to.equal(MyobCsvTransformer)
    expect(myob.CustomersCsvTransformer).to.equal(CustomersCsvTransformer)
    expect(myob.ItemsCsvTransformer).to.equal(ItemsCsvTransformer)
