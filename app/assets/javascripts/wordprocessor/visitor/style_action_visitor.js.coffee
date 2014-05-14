WordProcessor.Visitor = {} if not window.WordProcessor.Visitor?

class WordProcessor.Visitor.StyleActionVisitor extends WordProcessor.Visitor.ElementMorphVisitor

  constructor: (@styleMorphKlass, @apply=true) ->
    super

  startVisitLine: (lineMorph) ->
    super(lineMorph)
    if @apply
      @styleMorphKlass.applyStyle(lineMorph)
    else
      @styleMorphKlass.removeStyle(lineMorph)

  startVisitListItem: (listItemMorph) ->
    super(listItemMorph)
    if @apply
      @styleMorphKlass.applyStyle(listItemMorph)
    else
      @styleMorphKlass.removeStyle(listItemMorph)


