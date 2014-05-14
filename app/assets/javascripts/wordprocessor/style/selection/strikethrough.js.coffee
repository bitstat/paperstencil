window.WordProcessor.Style.Selection = {} if not window.WordProcessor.Style.Selection?

class WordProcessor.Style.Selection.StrikeThroughMorph extends WordProcessor.Style.SelectionStyleMorph

  @__name__ = "WordProcessor.Style.Selection.StrikeThroughMorph"
  @__class__: "style_selection_strikethroughmorph"
  @__attribute__: "data-style-selection-strikethroughmorph"

  constructor: (@node$) ->
    @node$ = $("<span style='text-decoration:line-through'>")  if not @node$?
    @node$.addClass(WordProcessor.Style.Selection.StrikeThroughMorph.__class__)
    super(@node$)

  @checkPresenceOfStyle: (node) ->

    while (node && node.nodeType == Node.ELEMENT_NODE)
      if getComputedStyle(node)["textDecoration"].indexOf("line-through") isnt -1
        return true
      node = node.parentNode;

    return false
