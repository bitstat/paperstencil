window.WordProcessor.Style.Element = {} if not window.WordProcessor.Style.Element?

class WordProcessor.Style.Element.BlockQuoteMorph extends WordProcessor.Style.ContentElementStyleMorph

  @__class__ : "block_quote_morph"

  constructor: (@node$) ->
    @node$ = $("<blockquote>") if not @node$?
    super(@node$)
    @node$.addClass(@.constructor.__class__)

  @applyStyle: (contentMorph) =>
    if contentMorph.node$.find(".#{@__class__}").size() > 0
      @removeStyle(contentMorph)
    else
      super(contentMorph)

