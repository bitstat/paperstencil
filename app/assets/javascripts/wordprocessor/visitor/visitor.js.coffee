window.WordProcessor.Visitor = {} if not window.WordProcessor.Visitor?

class WordProcessor.Visitor.ElementMorphVisitor

  constructor: () ->
    @visitHierarchy = []

  startVisitLine: (lineMorph) ->
#    console.log("start visiting line")
#    console.log(lineMorph.node$.get(0))
    @visitHierarchy.push(lineMorph)


  endVisitLine: (lineMorph) ->
#    console.log("end visiting line")
#    console.log(lineMorph.node$.get(0))
    @visitHierarchy.pop()

  startVisitList: (listMorph) ->
#    console.log("start visiting list")
#    console.log(listMorph.node$.get(0))
    @visitHierarchy.push(listMorph)

  endVisitList: (listMorph) ->
#    console.log("end visiting list")
#    console.log(listMorph.node$.get(0))
    @visitHierarchy.pop()

  startVisitListItem: (listItemMorph) ->
#    console.log("start visiting list item")
#    console.log(listItemMorph.node$.get(0))
    @visitHierarchy.push(listItemMorph)

  endVisitListItem: (listItemMorph) ->
#    console.log("end visiting list item")
#    console.log(listItemMorph.node$.get(0))
    @visitHierarchy.pop()

  startVisitTable: (tableMorph) ->
#    console.log("start visiting table")
#    console.log(tableMorph.node$.get(0))
    @visitHierarchy.push(tableMorph)

  endVisitTable: (tableMorph) ->
#    console.log("end visiting table")
#    console.log(tableMorph.node$.get(0))
    @visitHierarchy.pop()

  startVisitTableRow: (tableRow) ->
#    console.log("start visiting table row")
#    console.log(tableRow.node$.get(0))
    @visitHierarchy.push(tableRow)

  endVisitTableRow: (tableRow) ->
#    console.log("end visiting table row")
#    console.log(tableRow.node$.get(0))
    @visitHierarchy.pop()

  startVisitTableCell: (tableCell) ->
#    console.log("start visiting table cell")
#    console.log(tableCell.node$.get(0))
    @visitHierarchy.push(tableCell)

  endVisitTableCell: (tableCell) ->
#    console.log("end visiting table cell")
#    console.log(tableCell.node$.get(0))
    @visitHierarchy.pop()


  @startMorphFromRange: (range) ->
    sc = range.startContainer
    so = range.startOffset

    scMorph = WordProcessor.Core.ElementMorph.getMorph($(sc))
    if scMorph is undefined or scMorph is null
      ## For text node (or) style element, get content node
      contentNode$ = $(sc).closest(".#{WordProcessor.Element.ContentMorph.__class__}")
      startMorph = WordProcessor.Core.ElementMorph.getMorph(contentNode$)
    else if scMorph instanceof WordProcessor.Element.StructMorph
      startMorphNode = scMorph.node$.get(0).childNodes[so];
      startMorph = WordProcessor.Core.ElementMorph.getMorph($(startMorphNode))
    else if scMorph instanceof WordProcessor.Element.ContentMorph
      startMorph = scMorph

    startMorph

  @endMorphFromRange: (range) ->
    ec = range.endContainer
    eo = range.endOffset

    ecMorph = WordProcessor.Core.ElementMorph.getMorph($(ec))

    if ecMorph is undefined or ecMorph is null
      ## For text node (or) style element, get content node
      contentNode$ = $(ec).closest(".#{WordProcessor.Element.ContentMorph.__class__}")
      endMorph = WordProcessor.Core.ElementMorph.getMorph(contentNode$)
    else if ecMorph instanceof WordProcessor.Element.StructMorph
      endMorphNode = ecMorph.node$.get(0).childNodes[eo-1]
      endMorph = WordProcessor.Core.ElementMorph.getMorph($(endMorphNode))
    else if ecMorph instanceof WordProcessor.Element.ContentMorph
      endMorph = ecMorph

    endMorph

  @iterateOnSelection: (visitor) ->

    selection = window.getSelection()

    if selection.rangeCount > 0
      range = selection.getRangeAt(0)
    else
      range = document.createRange()
      txtNode = WordProcessor.Element.Struct.DocMorph.editBox.attachedTextNode()
      offset = WordProcessor.Element.Struct.DocMorph.editBox.getCaretPosition()
      range.setStart(txtNode, offset)
      range.setEnd(txtNode, offset)

    sc = range.startContainer
    so = range.startOffset

    ec = range.endContainer
    eo = range.endOffset

    ## create new range to accomodate widget partial selection ##
    rangeNew = document.createRange()

    sWidget = $(sc).closest(".#{WordProcessor.Element.Content.WidgetMorph.__class__}", $(sc).closest(".#{WordProcessor.Element.StructMorph.__class__}"))
    if sWidget.get(0)?
      rangeNew.setStartBefore(sWidget.get(0))
    else
      rangeNew.setStart(sc, so)

    eWidget = $(ec).closest(".#{WordProcessor.Element.Content.WidgetMorph.__class__}", $(sc).closest(".#{WordProcessor.Element.StructMorph.__class__}"))
    if eWidget.get(0)?
      rangeNew.setEndAfter(eWidget.get(0))
    else
      rangeNew.setEnd(ec, eo)

    selection.removeAllRanges()
    selection.addRange(rangeNew)

    startMorph = @startMorphFromRange(rangeNew)
    endMorph = @endMorphFromRange(rangeNew)

    return if (not (startMorph? and endMorph?))

    if (startMorph is endMorph) and (startMorph instanceof WordProcessor.Element.ContentMorph)
      startMorph.startVisit(visitor, endMorph)
    else
      parentMorphs = WordProcessor.Element.Struct.DocMorph.parentHierarchy(startMorph)

      for i in [parentMorphs.length - 1..0] by -1
        parentMorphs[i].visitSelf(visitor)

      startMorph.startVisit(visitor, endMorph)

      for pMorph in parentMorphs
        pMorph.endVisit(visitor)
        pMorph.visitNeighbour(visitor, endMorph)

    return {startMorph:startMorph, endMorph:endMorph, range: rangeNew}
