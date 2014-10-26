expect = require('chai').expect
myob = require('../src')
CsvTransformer = require('../src/CsvTransformer')
CustomersCsvTransformer = require('../src/CustomersCsvTransformer')
MyobConverter = require('../src/MyobConverter')

describe 'The library', ->

  it 'can be required', ->
    expect(myob.CsvTransformer).to.equal(CsvTransformer)
    expect(myob.CustomersCsvTransformer).to.equal(CustomersCsvTransformer)
    expect(myob.MyobConverter).to.equal(MyobConverter)
