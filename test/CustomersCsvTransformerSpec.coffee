_ = require('lodash')
expect = require('chai').expect
CustomersCsvTransformer = require('../src/CustomersCsvTransformer')
TestUtils = require('./util/TestUtils')

getFixtureCsv = -> TestUtils.readFixture('CUST.csv')
getFixtureSmallCsv = -> TestUtils.readFixture('CUST_subset.csv')
# getFixtureFullCsv = -> TestUtils.readFixture('CUST_full.csv')
getFixtureJson = -> TestUtils.readFixture('CUST.json')
getFixtureSmallJson = -> TestUtils.readFixture('CUST_subset.json')
getFixtureJsonHeaders = -> TestUtils.readFixture('CUST_headers.json')

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
      # console.log JSON.stringify(expectedJson)
      # console.log ''
      # console.log JSON.stringify(json)
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
    transformer.toJson(expectedCsv).then (json) ->
      transformer.fromJson(json).then (newCsv) ->
        transformer.toJson(newCsv).then (newJson) ->
          # CSV input and stringifier will produce slightly different whitespace, so we check only
          # the JSON.
          expect(newJson).to.deep.equal(json)
          expect(newJson).to.deep.equal(expectedJson)
          done()

  it 'can convert from JSON with subset of fields', (done) ->
    expectedJson = JSON.parse(getFixtureSmallJson())
    expectedCsv = getFixtureSmallCsv()
    # console.log expectedJson
    transformer.fromJson(expectedJson).then (newCsv) ->

      # console.log ''
      # console.log ''
      # console.log JSON.stringify(expectedCsv)
      # console.log ''
      # console.log JSON.stringify(newCsv)
      # console.log ''
      # console.log ''

      expect(newCsv).to.deep.equal(expectedCsv)
      transformer.toJson(expectedCsv).then (json) ->

        # console.log ''
        # console.log ''
        # console.log JSON.stringify(expectedJson)
        # console.log ''
        # console.log JSON.stringify(json)
        # console.log ''
        # console.log ''

        expect(json).to.deep.equal(expectedJson)
        done()
        # transformer.fromJson(json).then (newCsv) ->
    #     transformer.toJson(newCsv).then (newJson) ->
    #       # CSV input and stringifier will produce slightly different whitespace, so we check only
    #       # the JSON.
    #       expect(newJson).to.deep.equal(json)
    #       expect(newJson).to.deep.equal(expectedJson)
          # done()
