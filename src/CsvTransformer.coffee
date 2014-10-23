_ = require('underscore')
csv = require('csv')
Q = require('q')
JsonTransformer = require('./JsonTransformer')

class CsvTransformer extends JsonTransformer

  toJson: (data) -> @_toJson(data)

  _toJson: (data, args) ->
    args = _.extend({columns: true}, args)
    df = Q.defer()
    csv.parse data, args, (err, result) ->
      if err
        df.reject(err)
      else
        df.resolve(result)
    df.promise

  fromJson: (data) -> @_fromJson(data)

  _fromJson: (data) ->
    df = Q.defer()
    csv.stringify data, {header: true}, (err, result) ->
      if err
        df.reject(err)
      else
        df.resolve(result)
    df.promise

module.exports = CsvTransformer
