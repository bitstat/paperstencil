window.WordProcessor.Style.Selection = {} if not window.WordProcessor.Style.Selection?

class WordProcessor.Style.Selection.BoldMorph extends WordProcessor.Style.SelectionStyleMorph

  @__name__ = "WordProcessor.Style.Selection.BoldMorph"
  @__class__: "style_selection_boldmorph"
  @__attribute__: "data-style-selection-boldmorph"

  constructor: (@node$) ->
    @node$ = $("<span style='font-weight:bold'>") if not @node$?
    @node$.addClass(WordProcessor.Style.Selection.BoldMorph.__class__)

    super(@node$)

  @checkPresenceOfStyle: (node) ->
    fontWeight = getComputedStyle(node)["fontWeight"]
    fontWeight is "bold" or fontWeight is "700"