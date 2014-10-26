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

  it 'can convert to JSON', (done) ->
    csv = getSampleCsv()
    transformer.toJson(csv).then (json) ->
      expect(json).not.to.be.null
      expect(json.length).to.equal(103)
      done()

  it 'can convert from JSON', (done) ->
    csv = getSampleCsv()
    transformer.toJson(csv).then (json) ->
      transformer.fromJson(json).then (newCsv) ->
        expect(newCsv).to.deep.equal(csv)
        transformer.toJson(newCsv).then (newJson) ->
          # CSV input and stringifier will produce slightly different whitespace, so we check only
          # the JSON.
          expect(newJson).to.deep.equal(json)
          done()
