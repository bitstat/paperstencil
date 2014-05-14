WordProcessor.Visitor = {} if not window.WordProcessor.Visitor?

class WordProcessor.Visitor.StyleToggleActionVisitor extends WordProcessor.Visitor.ElementMorphVisitor

  constructor: (@styleMorphKlass) ->
    super
    @markForStyleRemoval = @_evalForStyleRemoval()

  startVisitLine: (lineMorph) ->
    super(lineMorph)
    @styleMorphKlass.toggleStyle(lineMorph, @markForStyleRemoval)

  startVisitListItem: (listItemMorph) ->
    super(listItemMorph)
    @styleMorphKlass.toggleStyle(listItemMorph, @markForStyleRemoval)

  _evalForStyleRemoval: ->
    nodes = WordProcessor.Util.getAllEffectivelyContainedNodes(window.getSelection().getRangeAt(0),
      (node) ->
        if node.nodeType is Node.TEXT_NODE
          return true
        return false
    )

    for node in nodes

      # "If neither node nor its parent is an Element, go to next element."
      continue if node.nodeType isnt Node.ELEMENT_NODE and (not node.parentNode or node.parentNode.nodeType isnt Node.ELEMENT_NODE)

      # "If node is not an Element, return the effective command value of its
      # parent for command."
      if node.nodeType is Node.ELEMENT_NODE
        isStylePresent = @styleMorphKlass.checkPresenceOfStyle(node)
      else
        isStylePresent = @styleMorphKlass.checkPresenceOfStyle(node.parentNode)

      if not isStylePresent
        return false


    return true