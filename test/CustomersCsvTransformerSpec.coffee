expect = require('chai').expect
CustomersCsvTransformer = require('../src/CustomersCsvTransformer')
TestUtils = require('./util/TestUtils')

getFixtureCsv = -> TestUtils.readFixture('CUST.csv')
getFixtureJson = -> TestUtils.readFixture('CUST.json')
getFixtureJsonHeaders = -> TestUtils.readFixture('CUST_headers.json')

describe 'A CsvTransformer', ->

  transformer = expectedCsv = expectedJson = null

  beforeEach ->
    transformer = new CustomersCsvTransformer()
    expectedCsv = getFixtureCsv()
    expectedJson = JSON.parse(getFixtureJson())
  afterEach -> transformer = expectedCsv = expectedJson = null

  xit 'can be constructed', -> expect(transformer).not.to.equal(null)

  xit 'can convert to JSON', (done) ->
    transformer.toJson(expectedCsv).then (json) ->
      expect(json).to.deep.equal(expectedJson)
      done()

  it 'can get json headers', ->
    expectedJsonHeaders = JSON.parse(getFixtureJsonHeaders())
    headers = transformer._getJsonHeaders(expectedJson)
    expect(headers).to.deep.equal(expectedJsonHeaders)
    console.log headers

  # it 'can convert from JSON', (done) ->
  #   expectedCsv = getFixtureCsv()
  #   expectedJson = JSON.parse(getFixtureJson())
  #   transformer.toJson(expectedCsv).then (json) ->
  #     transformer.fromJson(json).then (newCsv) ->
  #       console.log newCsv
        # transformer.toJson(newCsv).then (newJson) ->
        #   # CSV input and stringifier will produce slightly different whitespace, so we check only
        #   # the JSON.
        #   expect(newJson).to.deep.equal(json)
        #   expect(newJson).to.deep.equal(expectedJson)
        #   done()


