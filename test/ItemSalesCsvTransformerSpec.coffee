_ = require('lodash')
expect = require('chai').expect
ItemSalesCsvTransformer = require('../src/ItemSalesCsvTransformer')
FileUtils = require('./util/FileUtils')

getFixtureCsv = -> FileUtils.readFixture('ITEMSALE.csv')
getFixtureJson = -> FileUtils.readFixture('ITEMSALE.json')

describe 'A ItemSalesCsvTransformer', ->

  transformer = expectedCsv = expectedJson = null

  beforeEach ->
    transformer = new ItemSalesCsvTransformer()
    expectedCsv = getFixtureCsv()
    expectedJson = JSON.parse(getFixtureJson())
  afterEach -> transformer = expectedCsv = expectedJson = null

  it 'can be constructed', -> expect(transformer).not.to.equal(null)

  it 'can convert to JSON', (done) ->
    transformer.toJson(expectedCsv).then (json) ->
      expect(json).to.deep.equal(expectedJson)
      done()

  it 'can convert from JSON', (done) ->
    transformer.fromJson(expectedJson).then (newCsv) ->
      expect(newCsv).to.equal(expectedCsv)
      transformer.toJson(newCsv).then (newJson) ->
        expect(newJson).to.deep.equal(expectedJson)
        done()
