class JsonTransformer

  toJson: (data) -> throw new Error('Abstract method called')

  fromJson: (data) -> throw new Error('Abstract method called')

module.exports = JsonTransformer
