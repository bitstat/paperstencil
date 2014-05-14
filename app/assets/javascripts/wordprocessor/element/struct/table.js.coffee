window.WordProcessor.Element.Struct = {} if not window.WordProcessor.Element.Struct?

class WordProcessor.Element.Struct.TableMorph extends WordProcessor.Element.StructMorph

  @__name__ = "WordProcessor.Element.Struct.TableMorph"
  WordProcessor.Core.MorphMap[@__name__] = @

  @__class__: "element_struct_tablemorph"
  @__attribute__: "data-element-struct-tablemorph"

  @__table_border_show_class : 'table_border_show'
  @__table_border_hide_class : 'table_border_hide'

  @CONTEXT_MENU_OPTIONS :
    insertRowAbove:
      name: "Insert a row above"

    insertRowBelow:
      name: "Insert a row below"

    sep1: "---------"

    insertColumnLeft:
      name: "Insert a column on left"

    insertColumnRight:
      name: "Insert a column on right"

    sep2: "---------"

    removeRow:
      name: "Remove row"

    removeColumn:
      name: "Remove column"

    sep3: "---------"

    toggleTableBorder:
      name: "Toggle table border"

  constructor: (@inEditMode, @rowsCount=3, @colsCount=3, @canResize=true) ->
    @node$ = $("<table style='width:100%'>")
    super(@inEditMode, @node$)
    @node$.addClass(WordProcessor.Element.Struct.TableMorph.__class__)

    ## If this is set to true, when cell is created empty line will be appended to the cell
    @addLineAfterCellCreation=true

    if @rowsCount > 0
      for rCount in [1..@rowsCount]
        @insertRowAndCells()

    @showTableBorder = true
    @setTableBorder()

    @applyColResize()
    @makeResizable()

  rowMorph: (rowIndex) ->
    WordProcessor.Core.ElementMorph.getMorph($(@node$.get(0).rows[rowIndex]))

  merge: (thatTableMorph, afterRowNode$) ->

    return if not thatTableMorph? or not thatTableMorph.rowsCount > 0

    if thatTableMorph.colsCount > @colsCount
      newColCount = thatTableMorph.colsCount - @colsCount
      for i in [1..newColCount]
        @_insertColumn(-1) ## Insert new columns at end
    else if thatTableMorph.colsCount < @colsCount
      newColCount = @colsCount - thatTableMorph.colsCount
      for i in [1..newColCount]
        thatTableMorph._insertColumn(-1) ## Insert new columns at end

    for rowNode in thatTableMorph.getRowNodes$()
      $(rowNode).insertBefore(afterRowNode$)


  applyColResize: ->
    ## When one of the cell is reszied set size of all other cells of same column to resized cell ##
    @node$.on "resizestop", ".#{WordProcessor.Element.Struct.TableCellMorph.__class__}", (event, ui) =>
      td = ui.element.get(0)
      cellIndex = td.cellIndex
      adjacentCell = @node$.get(0).rows[0].cells[cellIndex+1]

      totalWidth = $(td).width() + $(adjacentCell).width()
      adjustedWidth = ui.size.width
      adjacentCellWidth = totalWidth - adjustedWidth

      ui.element.css({top: 0,left: 0});

      @node$.find("td:nth-child(#{cellIndex+1})").each( ->
        $(this).css({width: adjustedWidth})
      )

      @node$.find("td:nth-child(#{cellIndex+2})").each( ->
        $(this).css({width: adjacentCellWidth})
      )


  makeResizable: ->
    try
      @node$.resizable("destroy")
    catch
    @node$.resizable() if @inEditMode and @canResize

  getAllCellContents: ->
    contents = []
    cells = @node$.find(".#{WordProcessor.Element.Struct.TableCellMorph.__class__}")
    for cell in cells
      $.merge(contents, cell.node$.contents())

    contents

  ## This method is called from rowMorph ##
  handleContextOption: (key, rowMorph, cellMorph) =>
#    console.log(".......................")
#    console.log(key)
#    console.log(rowMorph.node$.get(0))
#    console.log(cellMorph.node$.get(0))
#    console.log(".......................")
    @[key](rowMorph, cellMorph)

  insertRowAbove: (rowMorph) ->
    @_insertRow(rowMorph.node$.get(0).rowIndex)

  insertRowBelow: (rowMorph) ->
    rowIndex= -1
    rowIndex = rowMorph.node$.get(0).rowIndex + 1 if rowMorph?
    @_insertRow(rowIndex)

  _insertRow: (rowIndex) ->
    rowMorph = @insertRowAndCells(rowIndex)
    @rowsCount = @rowsCount + 1
    rowMorph

  toggleTableBorder : ->
    if @showTableBorder
      @showTableBorder = false
    else
      @showTableBorder = true

    @setTableBorder()

  setTableBorder : ->
    if @showTableBorder
      @node$.removeClass(@.constructor.__table_border_hide_class) if @inEditMode
      @node$.addClass(@.constructor.__table_border_show_class)
    else
      @node$.removeClass(@.constructor.__table_border_show_class)
      @node$.addClass(@.constructor.__table_border_hide_class) if @inEditMode


  removeRow: (rowMorph) ->
    return if @rowsCount is 1

    @node$.get(0).deleteRow(rowMorph.node$.get(0).rowIndex)
    @rowsCount = @rowsCount - 1

  insertColumnLeft: (rowMorph, cellMorph) ->
    cellIndex = 0
    cellIndex = cellMorph.node$.get(0).cellIndex if cellMorph?
    @_insertColumn(cellIndex)

  insertColumnRight: (rowMorph, cellMorph) ->
    cellIndex= -1
    cellIndex = cellMorph.node$.get(0).cellIndex + 1 if cellMorph?
    @_insertColumn(cellIndex)

  getRowNodes$ : ->
    @node$.find(".#{WordProcessor.Element.Struct.TableRowMorph.__class__}")

  _insertColumn: (cellIndex) ->
    rows = @node$.find(".#{WordProcessor.Element.Struct.TableRowMorph.__class__}")
    for row in rows
      rowNode$ = $(row)
      rowMorph = WordProcessor.Core.ElementMorph.getMorph(rowNode$)
      rowMorph.insertCell(cellIndex)

    @colsCount = @colsCount + 1

  removeColumn:  (rowMorph, cellMorph) ->
    return if @colsCount is 1


    cellIndex = cellMorph.node$.get(0).cellIndex
    rows = @node$.find(".#{WordProcessor.Element.Struct.TableRowMorph.__class__}")

    for row in rows
      row.deleteCell(cellIndex)

    @colsCount = @colsCount - 1

  accept: (visitor, endVisit=false) =>
    if endVisit
      visitor.endVisitTable(@)
    else
      visitor.startVisitTable(@)

  assertThereIsLine: (direction) ->

    if direction is WordProcessor.WPCaret.DIRECTION_AFTER
      sib = @node$.get(0).nextSibling
    else if direction is WordProcessor.WPCaret.DIRECTION_BEFORE
      sib = @node$.get(0).previousSibling

    sibMorph = WordProcessor.Core.ElementMorph.getMorph($(sib)) if sib?

    if not sib or (not sibMorph instanceof WordProcessor.Element.Content.LineMorph)
      line = new WordProcessor.Element.Content.LineMorph(@inEditMode)

      if direction is WordProcessor.WPCaret.DIRECTION_AFTER
        line.node$.insertAfter(@node$)
      else if direction is WordProcessor.WPCaret.DIRECTION_BEFORE
        line.node$.insertBefore(@node$)

      line.setCaretFocus()

  insertRowAndCells: (rowIndex=-1) ->
    tableNode = @node$.get(0)

    row = tableNode.insertRow(rowIndex)
    rowMorph = new WordProcessor.Element.Struct.TableRowMorph(@inEditMode, @, $(row))

    cellWidth = (100 / @colsCount);
    if @colsCount > 0
      for cCount in [1..@colsCount]
        cellMorph = rowMorph.insertCell()
        cellMorph.node$.css('width', "#{cellWidth}%")

    rowMorph

  toJSONStruct: (fields=[], pictures=[]) ->

    design = {}
    design['meta'] = {'rowsCount' : @rowsCount, 'colsCount' : @colsCount, 'showTableBorder' : @showTableBorder, 'morph': @.constructor.__name__}
    design['data'] = []

    if @node$.get(0).rows?
      for row in @node$.get(0).rows
        rowMorph = WordProcessor.Core.ElementMorph.getMorph($(row))
        if rowMorph?
          rowStruct = rowMorph.toJSONStruct(fields, pictures)
          design["data"].push rowStruct['design_struct']

    { design_struct: design}


  @newEmptyInstanceFromDesign: (inEditMode, design_struct, parent_morph) ->
    meta = design_struct['meta']

    tableMorph = new @(inEditMode, 0, 0, false)
    tableMorph.addLineAfterCellCreation = false
    tableMorph.node$.css('width', "100%")
    tableMorph

  ## Override designToContent
  designToContent: (design_struct) ->
    data = design_struct['data']
    meta = design_struct['meta']

    for row_struct in data
      morphName = row_struct['meta']['morph']
      morphKlass = WordProcessor.Core.MorphMap[morphName] if morphName?

      continue if not morphKlass?

      rowMorph = @insertRowBelow()
      rowMorph.designToContent(row_struct)

    @.colsCount = meta['colsCount']
    @.addLineAfterCellCreation = true
    @canResize = true

    meta_table_border = meta['showTableBorder']
    if meta_table_border is undefined or  meta_table_border is null
      @showTableBorder = false
    else
      @showTableBorder = meta_table_border

    @setTableBorder()

    @makeResizable()
    @

  @insertTable: () ->

    eBox = WordProcessor.Element.Struct.DocMorph.editBox

    contentMorph = eBox.contentMorphOfattachedTextNode()
    return if not contentMorph?

    tableMorph = new @(true)

    if contentMorph instanceof  WordProcessor.Element.Content.ListItemMorph
      list = $(contentMorph.node$.get(0).parentNode)
      tableMorph.node$.insertAfter(list)
    else
      tableMorph.node$.insertAfter(contentMorph.node$)

    tableMorph.assertThereIsLine(WordProcessor.WPCaret.DIRECTION_BEFORE)
    tableMorph.assertThereIsLine(WordProcessor.WPCaret.DIRECTION_AFTER)
