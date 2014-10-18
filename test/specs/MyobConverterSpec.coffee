describe 'An MyobConverter', ->

  converter = null

  beforeEach -> converter = new MyobConverter()
  afterEach -> converter = null

  it 'can be constructed', ->
    expect(converter).not.toEqual(null)


