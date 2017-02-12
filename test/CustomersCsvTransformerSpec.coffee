_ = require('lodash')
expect = require('chai').expect
CustomersCsvTransformer = require('../src/CustomersCsvTransformer')
FileUtils = require('./util/FileUtils')

getFixtureCsv = -> FileUtils.readFixture('CUST.csv')
getFixtureSmallCsv = -> FileUtils.readFixture('CUST_subset.csv')
getFixtureJson = -> FileUtils.readFixture('CUST.json')
getFixtureSmallJson = -> FileUtils.readFixture('CUST_subset.json')
getFixtureJsonHeaders = -> FileUtils.readFixture('CUST_headers.json')

describe 'A CustomersCsvTransformer', ->

  transformer = expectedCsv = expectedJson = null

  beforeEach ->
    transformer = new CustomersCsvTransformer()
    expectedCsv = getFixtureCsv()
    expectedJson = JSON.parse(getFixtureJson())
  afterEach -> transformer = expectedCsv = expectedJson = null

  it 'can be constructed', -> expect(transformer).not.to.equal(null)

  it 'can convert to JSON', (done) ->
    transformer.toJson(expectedCsv).then (json) ->
      expect(json).to.deep.equal(expectedJson)
      done()

  it 'can get CSV headers', ->
    expectedJsonHeaders = JSON.parse(getFixtureJsonHeaders())
    origExpectedJson = _.cloneDeep(expectedJson)
    headers = transformer._getCsvHeaders(expectedJson)
    expect(headers).to.deep.equal(expectedJsonHeaders)
    # Ensure the data passed is not modified.
    expect(expectedJson).to.deep.equal(origExpectedJson)

  it 'can convert from JSON', (done) ->
    jsonResult = null
    transformer.toJson(expectedCsv).then (json) ->
      jsonResult = json
      transformer.fromJson(json)
    .then (newCsv) ->
      expect(newCsv).to.equal(expectedCsv)
      transformer.toJson(newCsv)
    .then (newJson) ->
      expect(newJson).to.deep.equal(jsonResult)
      expect(newJson).to.deep.equal(expectedJson)
      done()
    .done()

  it 'can convert from JSON with subset of fields', (done) ->
    expectedJson = JSON.parse(getFixtureSmallJson())
    expectedCsv = getFixtureSmallCsv()
    transformer.fromJson(expectedJson, allHeaders: false).then (newCsv) ->
      expect(newCsv).to.deep.equal(expectedCsv)
      transformer.toJson(expectedCsv)
    .then (json) ->
      expect(json).to.deep.equal(expectedJson)
      done()
    .done()
