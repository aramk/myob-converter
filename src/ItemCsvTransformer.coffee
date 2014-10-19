CsvTransformer = require('./CsvTransformer')

class ItemCsvTransformer extends CsvTransformer

  toJson: (data) ->
    super(data).then(csvJson)

  fromJson: (data) ->
    # TODO

module.exports = ItemCsvTransformer
