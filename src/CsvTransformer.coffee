csv = require('csv');
Q = require('q');
JsonTransformer = require('./JsonTransformer')

class CsvTransformer extends JsonTransformer

  toJson: (data) ->
    df = Q.defer()
    csv.parse data, {columns: true}, (err, result) ->
      if err
        df.reject(err)
      else
        df.resolve(result)
    df.promise

  fromJson: (data) ->
    df = Q.defer()
    csv.stringify data, {header: true}, (err, result) ->
      if err
        df.reject(err)
      else
        df.resolve(result)
    df.promise

module.exports = CsvTransformer
