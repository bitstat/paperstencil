window.WordProcessor.Style.Selection = {} if not window.WordProcessor.Style.Selection?

class WordProcessor.Style.Selection.ItalicMorph extends WordProcessor.Style.SelectionStyleMorph

  @__name__ = "WordProcessor.Style.Selection.ItalicMorph"
  @__class__: "style_selection_italicmorph"
  @__attribute__: "data-style-selection-italicmorph"

  constructor: (@node$) ->
    @node$ = $("<span style='font-style:italic'>")  if not @node$?
    @node$.addClass(WordProcessor.Style.Selection.ItalicMorph.__class__)
    super(@node$)

  @checkPresenceOfStyle: (node) ->
    getComputedStyle(node)["fontStyle"] is "italic"
