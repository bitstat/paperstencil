WordProcessor.Visitor = {} if not window.WordProcessor.Visitor?

class WordProcessor.Visitor.DeleteVisitor extends WordProcessor.Visitor.ElementMorphVisitor

  constructor: () ->
    @fullySelectedOldMorphs=[]
    super

  startVisitLine: (lineMorph) ->
    super(lineMorph)

  endVisitLine: (lineMorph) ->
    super(lineMorph)
    @_deleteContentMorph(lineMorph)

  startVisitTable: (tableMorph) ->
    super(tableMorph)

  endVisitTable: (tableMorph) ->
    super(tableMorph)
    @_deleteStructMorph(tableMorph)

  startVisitTableRow: (tableRowMorph) ->
    super(tableRowMorph)

  endVisitTableRow: (tableRowMorph) ->
    super(tableRowMorph)

  startVisitTableCell: (tableCellMorph) ->
    super(tableCellMorph)

  endVisitTableCell: (tableCellMorph) ->
    super(tableCellMorph)

  startVisitList: (listMorph) ->
    super(listMorph)

  endVisitList: (listMorph) ->
    super(listMorph)
    @_deleteStructMorph(listMorph)

  startVisitListItem: (listItemMorph) ->
    super(listItemMorph)

  endVisitListItem: (listItemMorph) ->
    super(listItemMorph)
    @_deleteContentMorph(listItemMorph)

  _deleteContentMorph: (morph) ->
    selection = morph.getRangeOfSelection()

    if (not selection["isFullSelection"]) and selection["range"]?
      range = selection["range"]
      range.deleteContents()
      @_markForRemoval(morph) if WordProcessor.Util.isEmptyNode(morph.node$.get(0))
    else if selection["isFullSelection"]
      range = document.createRange()
      range.setStartBefore(morph.node$.get(0).firstChild)
      range.setEndAfter(morph.node$.get(0).lastChild)
      range.deleteContents()
      @_markForRemoval(morph)

  _deleteStructMorph: (morph) ->
    selection = morph.getRangeOfSelection()
    @_markForRemoval(morph) if selection["isFullSelection"]

  _markForRemoval: (morph) ->
    parentMorph = @visitHierarchy[@visitHierarchy.length-1]
    parentMorph = WordProcessor.Element.Struct.DocMorph.root if not parentMorph?
    @fullySelectedOldMorphs.push({morph : morph, parentMorph: parentMorph})










