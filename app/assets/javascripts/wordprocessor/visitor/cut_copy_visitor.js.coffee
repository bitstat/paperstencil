WordProcessor.Visitor = {} if not window.WordProcessor.Visitor?

class WordProcessor.Visitor.CutCopyVisitor extends WordProcessor.Visitor.ElementMorphVisitor

  constructor: (@doCut=true) ->
    @newlyConstructed = []
    @visitHierarchyOfNewlyConstructed = []

    super

  startVisitLine: (lineMorph) ->
    super(lineMorph)

    selectionVal = lineMorph.fetchSelectionAsMorph(@doCut)
    newLineMorph = null

    if selectionVal? and selectionVal["morph"]?
      newLineMorph = selectionVal["morph"]

      @_removeFocusDenyMorphs(newLineMorph.node$)
      @_addMorph(newLineMorph)

    @visitHierarchyOfNewlyConstructed.push(newLineMorph)

  endVisitLine: (lineMorph) ->
    super(lineMorph)
    @visitHierarchyOfNewlyConstructed.pop()

  startVisitTable: (tableMorph) ->
    super(tableMorph)
    newTableMorph = new WordProcessor.Element.Struct.TableMorph(true, 0, tableMorph.colsCount)

    @_addMorph(newTableMorph)
    @visitHierarchyOfNewlyConstructed.push(newTableMorph)

  endVisitTable: (tableMorph) ->
    super(tableMorph)
    @visitHierarchyOfNewlyConstructed.pop()


  startVisitTableRow: (tableRowMorph) ->
    super(tableRowMorph)
#    console.log("visiting table row")
    newTableRowMorph = @_addTableRow()

#    console.log("Inserted a row..")
    @visitHierarchyOfNewlyConstructed.push(newTableRowMorph)

  endVisitTableRow: (tableRowMorph) ->
    super(tableRowMorph)
    @visitHierarchyOfNewlyConstructed.pop()

  startVisitTableCell: (tableCellMorph) ->
    super(tableCellMorph)
#    console.log("visiting table cell")

    ## table cells are inserted as part of startVisitTableRow call itself
    newTableCell = @_getTableCell(tableCellMorph.node$.get(0).cellIndex)
    @visitHierarchyOfNewlyConstructed.push(newTableCell)

  endVisitTableCell: (tableCellMorph) ->
    super(tableCellMorph)
    @visitHierarchyOfNewlyConstructed.pop()

  startVisitList: (listMorph) ->
    super(listMorph)
#    console.log("visiting list")
    newListMorph = new WordProcessor.Element.Struct.ListMorph(true, listMorph.type)
    @_addMorph(newListMorph)
    @visitHierarchyOfNewlyConstructed.push(newListMorph)

  endVisitList: (listMorph) ->
    super(listMorph)
    @visitHierarchyOfNewlyConstructed.pop()

  startVisitListItem: (listItemMorph) ->
    super(listItemMorph)
#    console.log("visiting list item")

    selectionVal = listItemMorph.fetchSelectionAsMorph(@doCut)
    newListItem = null

    if selectionVal? and selectionVal["morph"]?
      newListItem = selectionVal["morph"]
      @_removeFocusDenyMorphs(newListItem.node$)
      @_addMorph(newListItem)

    @visitHierarchyOfNewlyConstructed.push(newListItem)

#    console.log(@newlyConstructed[@newlyConstructed.length-1].node$.get(0))

  endVisitListItem: (listItemMorph) ->
    super(listItemMorph)
    @visitHierarchyOfNewlyConstructed.pop()

  _removeFocusDenyMorphs: (node$) ->
    WordProcessor.Element.Content.WidgetMorph.removeAll(node$) if not @doCut

  _addMorph: (newMorph) ->
    if @visitHierarchyOfNewlyConstructed.length is 0
      @newlyConstructed.push(newMorph)
    else
      lastMorph = @visitHierarchyOfNewlyConstructed[@visitHierarchyOfNewlyConstructed.length-1]
      lastMorph.node$.append(newMorph.node$)

  _addTableRow: () ->
    rowMorph = null

    if @visitHierarchyOfNewlyConstructed.length is 0
      throw "visitHierarchyOfNewlyConstructed length is 0. Need table morph in visitHierarchyOfNewlyConstructed"
    else
      lastMorph = @visitHierarchyOfNewlyConstructed[@visitHierarchyOfNewlyConstructed.length-1]
      throw "visitHierarchyOfNewlyConstructed last item wasn't table morph" if not (lastMorph instanceof WordProcessor.Element.Struct.TableMorph)
      rowMorph = lastMorph.insertRowBelow()

    return rowMorph

  _getTableCell: (index) ->
    cellMorph = null

    if @visitHierarchyOfNewlyConstructed.length is 0
      throw "visitHierarchyOfNewlyConstructed length is 0. Need table row morph in visitHierarchyOfNewlyConstructed"
    else
      lastMorph = @visitHierarchyOfNewlyConstructed[@visitHierarchyOfNewlyConstructed.length-1]
      throw "visitHierarchyOfNewlyConstructed last item wasn't table row morph" if not (lastMorph instanceof WordProcessor.Element.Struct.TableRowMorph)
      cellMorph = lastMorph.cellMorph(index)
      lastMorph['copiedCellsToClipboard']=[] if not lastMorph['copiedCellsToClipboard']?
      lastMorph['copiedCellsToClipboard'].push(cellMorph)

    return cellMorph






