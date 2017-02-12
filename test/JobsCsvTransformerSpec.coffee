expect = require('chai').expect
fs = require('fs')
path = require('path')
JobsCsvTransformer = require('../src/JobsCsvTransformer')
FileUtils = require('./util/FileUtils')
_ = require('lodash')

getFixtureCsv = -> FileUtils.readFixture('JOBS.csv')
getFixtureJson = -> FileUtils.readFixture('JOBS.json')

describe 'A JobsCsvTransformer', ->

  transformer = expectedCsv = expectedJson = null

  beforeEach ->
    transformer = new JobsCsvTransformer()
    expectedCsv = getFixtureCsv()
    expectedJson = JSON.parse(getFixtureJson())
  afterEach -> transformer = null

  it 'can be constructed', -> expect(transformer).not.to.equal(null)

  it 'can convert to JSON', (done) ->
    transformer.toJson(expectedCsv)
      .then (json) ->
        expect(json).deep.to.equal(expectedJson)
        done()
      .done()

  it 'can convert from JSON', (done) ->
    transformer.fromJson(expectedJson)
      .then (newCsv) ->
        expect(newCsv).to.deep.equal(expectedCsv)
        transformer.toJson(newCsv)
      .then (newJson) ->
        expect(newJson).to.deep.equal(expectedJson)
        done()
      .done()

  it 'can convert from a subset of JSON', (done) ->
    subsetJson = _.cloneDeep(expectedJson)
    fieldsToRemove = ['Start Date', 'End Date']
    _.each subsetJson, (row) ->
      _.each fieldsToRemove, (field) ->
        delete row[field]
    transformer.fromJson(subsetJson)
      .then (newCsv) ->
        expect(newCsv).to.deep.equal(expectedCsv)
        done()
      .done()
