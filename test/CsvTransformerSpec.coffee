expect = require('chai').expect
fs = require('fs')
path = require('path')
CsvTransformer = require('../src/CsvTransformer')

getSampleCsv = -> fs.readFileSync(path.join(__dirname, 'fixtures', 'ITEM.csv'), 'utf8')

describe 'A CsvTransformer', ->

  transformer = null

  beforeEach -> transformer = new CsvTransformer()
  afterEach -> transformer = null

  it 'can be constructed', -> expect(transformer).not.to.equal(null)

  it 'can convert to JSON', ->
    csv = getSampleCsv()
    transformer.toJson(csv).then (json) ->
#      console.log json
      expect(json).not.to.be.null

