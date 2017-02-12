_ = require('lodash')
expect = require('chai').expect
ItemSalesCsvTransformer = require('../src/ItemSalesCsvTransformer')
FileUtils = require('./util/FileUtils')

getFixtureCsv = -> FileUtils.readFixture('ITEMSALE.csv')
getFixtureJson = -> FileUtils.readFixture('ITEMSALE.json')
getFixtureCsv2 = -> FileUtils.readFixture('ITEMSALE_2.csv')
getFixtureJson2 = -> FileUtils.readFixture('ITEMSALE_2.json')
getFixtureJson2Subset = -> FileUtils.readFixture('ITEMSALE_2_subset.json')

describe 'A ItemSalesCsvTransformer', ->

  transformer = expectedCsv = expectedJson = null

  beforeEach ->
    transformer = new ItemSalesCsvTransformer()
    expectedCsv = getFixtureCsv()
    expectedJson = JSON.parse(getFixtureJson())
  afterEach -> transformer = expectedCsv = expectedJson = null

  it 'can be constructed', -> expect(transformer).not.to.equal(null)

  it 'can convert to JSON', (done) ->
    transformer.toJson(expectedCsv)
      .then (json) ->
        expect(json).to.deep.equal(expectedJson)
        done()
      .done()

  it 'can convert from JSON', (done) ->
    transformer.fromJson(expectedJson)
      .then (newCsv) ->
        expect(newCsv).to.equal(expectedCsv)
        transformer.toJson(newCsv)
      .then (newJson) ->
        expect(newJson).to.deep.equal(expectedJson)
        done()
      .done()

  it 'can convert to JSON with empty values in the last cell', (done) ->
    expectedCsv = getFixtureCsv2()
    expectedJson = JSON.parse(getFixtureJson2())
    transformer.toJson(expectedCsv)
      .then (json) ->
        expect(json).to.deep.equal(expectedJson)
        done()
      .done()

  it 'can convert from JSON with null values in the last cell', (done) ->
    expectedCsv = getFixtureCsv2()
    expectedJson = JSON.parse(getFixtureJson2())
    transformer.fromJson(expectedJson)
      .then (newCsv) ->
        expect(newCsv).to.equal(expectedCsv)
        transformer.toJson(newCsv)
      .then (newJson) ->
        expect(newJson).to.deep.equal(expectedJson)
        done()
      .done()

  it 'can convert from JSON with empty values in the last cell ', (done) ->
    expectedCsv = getFixtureCsv2()
    transformer.fromJson(JSON.parse(getFixtureJson2Subset()))
      .then (newCsv) ->
        expect(newCsv).to.equal(expectedCsv)
        transformer.toJson(newCsv)
      .then (newJson) ->
        # Full set of CSV fields should generate the full set of JSON fields.
        expect(newJson).to.deep.equal(JSON.parse(getFixtureJson2()))
        done()
      .done()
