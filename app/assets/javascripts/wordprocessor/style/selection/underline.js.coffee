window.WordProcessor.Style.Selection = {} if not window.WordProcessor.Style.Selection?

class WordProcessor.Style.Selection.UnderLineMorph extends WordProcessor.Style.SelectionStyleMorph

  @__name__ = "WordProcessor.Style.Selection.UnderLineMorph"
  @__class__: "style_selection_underlinehmorph"
  @__attribute__: "data-style-selection-underlinehmorph"

  constructor: (@node$) ->
    @node$ = $("<span style='text-decoration:underline'>")  if not @node$?
    @node$.addClass(WordProcessor.Style.Selection.UnderLineMorph.__class__)
    super(@node$)

  @checkPresenceOfStyle: (node) ->

    while (node && node.nodeType == Node.ELEMENT_NODE)
      if getComputedStyle(node)["textDecoration"].indexOf("underline") isnt -1
        return true
      node = node.parentNode;

    return false
