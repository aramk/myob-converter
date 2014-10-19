expect = require('chai').expect
myob = require('../src')
CsvTransformer = require('../src/CsvTransformer')
MyobConverter = require('../src/MyobConverter')

describe 'The library', ->

  it 'can be required', ->
    expect(myob.CsvTransformer).to.equal(CsvTransformer)
    expect(myob.MyobConverter).to.equal(MyobConverter)
