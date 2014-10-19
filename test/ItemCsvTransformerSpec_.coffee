expect = require('chai').expect
ItemCsvTransformer = require('../src/ItemCsvTransformer')

describe 'An ItemCsvTransformer', ->

  transformer = null

  beforeEach -> transformer = new ItemCsvTransformer()
  afterEach -> transformer = null

  it 'can be constructed', ->
    expect(transformer).not.to.equal(null)


