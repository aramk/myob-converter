expect = require('chai').expect
CustomersCsvTransformer = require('../src/CustomersCsvTransformer')
TestUtils = require('./util/TestUtils')

getFixtureCsv = -> TestUtils.readFixture('CUST.csv')
getFixtureJson = -> TestUtils.readFixture('CUST.json')

describe 'A CsvTransformer', ->

  transformer = null

  beforeEach -> transformer = new CustomersCsvTransformer()
  afterEach -> transformer = null

  it 'can be constructed', -> expect(transformer).not.to.equal(null)

  it 'can convert to JSON', (done) ->
    expectedCsv = getFixtureCsv()
    expectedJson = JSON.parse(getFixtureJson())
    transformer.toJson(expectedCsv).then (json) ->
      expect(json).to.deep.equal(expectedJson)
      done()

  it 'can convert from JSON', (done) ->
    expectedCsv = getFixtureCsv()
    expectedJson = JSON.parse(getFixtureJson())
    transformer.toJson(expectedCsv).then (json) ->
      transformer.fromJson(json).then (newCsv) ->
        console.log newCsv
        transformer.toJson(newCsv).then (newJson) ->
          # CSV input and stringifier will produce slightly different whitespace, so we check only
          # the JSON.
          expect(newJson).to.deep.equal(json)
          expect(newJson).to.deep.equal(expectedJson)
          done()
