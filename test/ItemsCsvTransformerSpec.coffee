expect = require('chai').expect
fs = require('fs')
path = require('path')
ItemsCsvTransformer = require('../src/ItemsCsvTransformer')
TestUtils = require('./util/TestUtils')
_ = require('lodash')

getFixtureCsv = -> TestUtils.readFixture('ITEM.csv')
getFixtureJson = -> TestUtils.readFixture('ITEM.json')

describe 'A ItemsCsvTransformer', ->

  transformer = expectedCsv = expectedJson = null

  beforeEach ->
    transformer = new ItemsCsvTransformer()
    expectedCsv = getFixtureCsv()
    expectedJson = JSON.parse(getFixtureJson())
  afterEach -> transformer = null

  it 'can be constructed', -> expect(transformer).not.to.equal(null)

  it 'can convert to JSON', (done) ->
    transformer.toJson(expectedCsv).then (json) ->
      expect(json).deep.to.equal(expectedJson)
      done()

  it 'can convert from JSON', (done) ->
    transformer.fromJson(expectedJson).then (newCsv) ->
      expect(newCsv).to.deep.equal(expectedCsv)
      transformer.toJson(newCsv).then (newJson) ->
        expect(newJson).to.deep.equal(expectedJson)
        done()

  it 'can convert from a subset of JSON', (done) ->
    subsetJson = _.cloneDeep(expectedJson)
    fieldsToRemove = ['Buy', 'Item Picture', 'Description']
    _.each subsetJson, (row) ->
      _.each fieldsToRemove, (field) ->
        delete row[field]
    transformer.fromJson(subsetJson).then (newCsv) ->
      expect(newCsv).to.deep.equal(expectedCsv)
      done()
