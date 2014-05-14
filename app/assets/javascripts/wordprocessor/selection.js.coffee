class WordProcessor.Selection
  constructor: (@node$, @selectionMarker) ->
    @initSelection = false
    @_registerForClick()

    @morphAndOffsetRange = []

  addForSelection: (txtNode, offset) ->
    @morphAndOffsetRange.push({txtNode:txtNode, offset:offset})

    if @morphAndOffsetRange.length is 2
      sel = window.getSelection()
      range = document.createRange()

      start = @morphAndOffsetRange[0]
      end = @morphAndOffsetRange[1]

      range.setStart(start.txtNode, start.offset)
      range.setEnd(end.txtNode, end.offset)

      sel.removeAllRanges()
      sel.addRange(range)

      @_toggleInitSelection()
      @morphAndOffsetRange = []
      @node$.removeClass("selectionMarkerOn")
    else
      @node$.addClass("selectionMarkerOn")

  _registerForClick: () ->
    @node$.click (e) =>
      @_toggleInitSelection()

  _toggleInitSelection: () ->
      if @initSelection
        @initSelection = false
        @node$.removeClass("selectionMarkerOn")
      else
        @initSelection = true

        @selectionMarker.length = 0;
        @selectionMarker.push(@)

        @node$.addClass("selectionMarkerOn")

  @registerAsSelectTool : (node$, selectionMarker) ->
    new @(node$, selectionMarker)





