window.WordProcessor.Element.Struct = {} if not window.WordProcessor.Element.Struct?

class WordProcessor.Element.Struct.TableRowMorph extends WordProcessor.Element.StructMorph

  @__name__ = "WordProcessor.Element.Struct.TableRowMorph"
  WordProcessor.Core.MorphMap[@__name__] = @

  @__class__: "element_struct_tablerowmorph"
  @__attribute__: "data-element-struct-tablerowmorph"

  constructor: (@inEditMode, @tableMorph, @node$) ->
    @node$ = $("<tr>") if not @node$? or not @node$.get(0)?
    @node$.addClass(WordProcessor.Element.Struct.TableRowMorph.__class__)
    super(@inEditMode, @node$)


  ## This method is called from CellMorph ##
  handleContextOption: (key, cellMorph) =>
    tableNode$ = @node$.closest(".#{WordProcessor.Element.Struct.TableMorph.__class__}")
    tableMorph = WordProcessor.Core.ElementMorph.getMorph(tableNode$)
    tableMorph.handleContextOption(key, @, cellMorph)

  accept: (visitor, endVisit=false) =>
    if endVisit
      visitor.endVisitTableRow(@)
    else
      visitor.startVisitTableRow(@)

  cellMorph: (cellIndex) ->
    WordProcessor.Core.ElementMorph.getMorph($(@node$.get(0).cells[cellIndex]))

  insertCell: (cellIndex=-1, canResize=true) ->
    rowNode = @node$.get(0)
    cell = rowNode.insertCell(cellIndex)
    cellMorph = new WordProcessor.Element.Struct.TableCellMorph(@inEditMode, @, $(cell), canResize)
    if @tableMorph.addLineAfterCellCreation
      cellLine = new WordProcessor.Element.Content.LineMorph(@inEditMode)
      cellMorph.node$.append(cellLine.node$);

    cellMorph

  toJSONStruct: (fields=[], pictures=[]) ->

    design = {}
    design['meta'] = {'morph': @.constructor.__name__}
    design['data'] = []

    if @node$.get(0).cells?
      for cell in @node$.get(0).cells
        cellMorph = WordProcessor.Core.ElementMorph.getMorph($(cell))
        if cellMorph?
          cellStruct = cellMorph.toJSONStruct(fields, pictures)
          design["data"].push cellStruct['design_struct']

    { design_struct: design}


  ## Override designToContent
  designToContent: (design_struct) ->
    data = design_struct['data']
    meta = design_struct['meta']

    for cell_struct in data
      morphName = cell_struct['meta']['morph']
      morphKlass = WordProcessor.Core.MorphMap[morphName] if morphName?

      continue if not morphKlass?

      cellMorph = @insertCell()
      cellMorph.designToContent(cell_struct)
      meta = cell_struct['meta']
      cellMorph.node$.css('width', "#{meta['width']}%") if meta['width']?

    @
