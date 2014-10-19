csv = require('csv');
Q = require('q');
JsonTransformer = require('./JsonTransformer')

class CsvTransformer extends JsonTransformer

  toJson: (data) ->
    df = Q.defer()
    csv.parse data, {columns: true}, (err, result) ->
      debugger
      if err
        df.reject(err)
      else
        df.resolve(result)
    df.promise

module.exports = CsvTransformer
