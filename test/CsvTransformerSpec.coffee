expect = require('chai').expect
fs = require('fs')
path = require('path')
CsvTransformer = require('../src/CsvTransformer')
TestUtils = require('./util/TestUtils')
_ = require('lodash')

getFixtureCsv = -> TestUtils.readFixture('ITEM.csv')
getFixtureJson = -> TestUtils.readFixture('ITEM.json')

describe 'A CsvTransformer', ->

  transformer = expectedCsv = expectedJson = null

  beforeEach ->
    transformer = new CsvTransformer()
    expectedCsv = getFixtureCsv()
    expectedJson = JSON.parse(getFixtureJson())
  afterEach -> transformer = null

  it 'can be constructed', -> expect(transformer).not.to.equal(null)

  # TODO(aramk) Empty string values should be changed to null in the JSON. This superclass does't
  # do it yet.

  xit 'can convert to JSON', (done) ->
    transformer.toJson(expectedCsv).then (json) ->
      expect(json).deep.to.equal(expectedJson)
      done()

  xit 'can convert from JSON', (done) ->
    transformer.fromJson(expectedJson).then (newCsv) ->
      expect(newCsv).to.deep.equal(expectedCsv)
      transformer.toJson(newCsv).then (newJson) ->
        # CSV input and stringifier will produce slightly different whitespace, so we check only
        # the JSON.
        expect(newJson).to.deep.equal(expectedJson)
        done()
