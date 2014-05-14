WordProcessor.Visitor = {} if not window.WordProcessor.Visitor?

class WordProcessor.Visitor.ListActionCollectVisitor extends WordProcessor.Visitor.ElementMorphVisitor

  constructor: (@type) ->
    @type = WordProcessor.Element.Struct.ListMorph.TYPE_OL if not @type?
    @newlyConstructed = []
    @breakCollection = false
    @lastVisitedContentMorph = null
    super

  startVisitLine: (lineMorph) ->
    super(lineMorph)

    return if @breakCollection
    @lastVisitedContentMorph = lineMorph

    item = new WordProcessor.Element.Content.ListItemMorph(true)
    item.appendContent(lineMorph.node$.contents())

    lastItem = @newlyConstructed.pop()
    if (not lastItem?) or (not (lastItem instanceof WordProcessor.Element.Struct.ListMorph))

      @newlyConstructed.push(lastItem) if lastItem?

      list = new WordProcessor.Element.Struct.ListMorph(true, @type)
      list.addItem(item)
      @newlyConstructed.push(list)
    else
      lastItem.addItem(item)
      @newlyConstructed.push(lastItem)

  startVisitListItem: (listItemMorph) ->
    super(listItemMorph)

    return if @breakCollection
    @lastVisitedContentMorph = listItemMorph

    line = new WordProcessor.Element.Content.LineMorph(true)
    line.appendContent(listItemMorph.node$.contents())
    @newlyConstructed.push(line)

  startVisitTable: (tableMorph) ->
    super(tableMorph)

    @breakCollection = true if @newlyConstructed.length > 0


  startVisitTableCell: (tableCell) ->
    super(tableCell)

    @breakCollection = true if @newlyConstructed.length > 0
