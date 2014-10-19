expect = require('chai').expect
MyobConverter = require('../src/MyobConverter')

describe 'An MyobConverter', ->

  converter = null

  beforeEach -> converter = new MyobConverter()
  afterEach -> converter = null

  it 'can be constructed', ->
    expect(converter).not.to.equal(null)
