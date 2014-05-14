window.WordProcessor.Element.Struct = {} if not window.WordProcessor.Element.Struct?

class WordProcessor.Element.Struct.DocMorph extends WordProcessor.Element.StructMorph

  @__name__ = "WordProcessor.Element.Struct.DocMorph"
  @__class__: "element_struct_docmorph"
  @__attribute__: "data-element-struct-docmorph"

  WordProcessor.Core.MorphMap[@__name__] = @

  constructor: (@inEditMode, @node$) ->
    super(@inEditMode, @node$)
    @node$.addClass(WordProcessor.Element.Struct.DocMorph.__class__);
    @node$.attr(WordProcessor.Element.Struct.DocMorph.__attribute__, true);

    if @inEditMode
      @node$.attr("tabIndex", 0);

      @_overrideKeyboardShortcuts()

  addLine: (lineMorph, afterThisLine = null) ->
    if afterThisLine?
      lineMorph.node$.insertAfter(afterThisLine.node$);
    else
      @node$.append(lineMorph.node$)

  visitNeighbour: (visitor, endContentMorph) ->
    ## This is root morph. Do nothing.
    return

  startVisit: (visitor, endContentMorph) ->
    ## This is root morph. Do nothing.
    return

  accept: (visitor, endVisit=false) =>
    ## This is root morph. Do nothing.
    return

  @hasSelection: () ->
    sel = window.getSelection()
    return false if not sel.rangeCount > 0

    range = sel.getRangeAt(0);
    return false if (range.startContainer is range.endContainer and range.startOffset is range.endOffset)

    true

  @parentHierarchy: (startMorph) ->

    parentMorphList = []
    parentMorph = startMorph.parentMorph()

    while parentMorph isnt WordProcessor.Element.Struct.DocMorph.root
      parentMorphList.push(parentMorph)
      parentMorph = parentMorph.parentMorph()

    parentMorphList

  assertThereIsLineAtEnd: ()->
    lastChild = @node$.get(0).lastChild
    lastChildMorph = WordProcessor.Core.ElementMorph.getMorph($(lastChild)) if lastChild?

    if not lastChildMorph or not (lastChildMorph instanceof WordProcessor.Element.Content.LineMorph)
      line = new WordProcessor.Element.Content.LineMorph(@inEditMode)
      @node$.append(line.node$)

  setCaretFocus: (firstLine=true)->

    return if not @inEditMode

    node = @node$.get(0)
    if firstLine
      line$ = $(node.children[0])
    else
      line$ = $(node.children[node.children.length-1])

    lineMorph = WordProcessor.Core.ElementMorph.getMorph(line$);

    if (not lineMorph) or (not lineMorph instanceof WordProcessor.Element.Content.LineMorph)
      lineMorph = new WordProcessor.Element.Content.LineMorph(@inEditMode);
      @addLine(lineMorph);

    if firstLine
      lineMorph.setCaretFocus()
    else
      lastTxtNode = lineMorph.filterCurrentNodeForActionableNode(WordProcessor.WPCaret.DIRECTION_BEFORE)
      lineMorph.setCaretFocus() if not lastTxtNode?
      lineMorph.setFocusonTextNode(lastTxtNode, lastTxtNode.nodeValue.length)

  _overrideKeyboardShortcuts: ->
    key "ctrl+c", ->
      WordProcessor.UIActions.copy()
      return false

    key "ctrl+x", ->
      WordProcessor.UIActions.cut()
      return false

    key "ctrl+v", ->
      WordProcessor.UIActions.paste()
      return false

    key "ctrl+b", ->
      WordProcessor.UIActions.bold()
      return false

    key "ctrl+i", ->
      WordProcessor.UIActions.italic()
      return false

    key "ctrl+u", ->
      WordProcessor.UIActions.underline()
      return false

    key "ctrl+s", ->
      WordProcessor.UIActions.save()
      return false

    key "delete", ->
      WordProcessor.UIActions.delete()
      return false

  toJSONStruct: (fields=[], pictures=[]) ->
    super(fields, pictures)

  serialize: ->
    fields = []
    pictures = []
    designJSONStruct = @toJSONStruct(fields, pictures)
    designJSONStruct["fields"] =  fields
    designJSONStruct["pictures"] =  pictures
    return  designJSONStruct

  @assembleDocument: (fetch_design_struct_url, fetch_fields_url, fetch_pictures_url) ->

    loadFields = true
    loadPictures = true

    firstLine = null

    docPromise = $.get(fetch_design_struct_url)

    docPromise.done (data) =>
      if data["status"] is "ok"
        @root.designToContent(data["design_struct"])
        fieldPromise = WordProcessor.Element.Content.Widget.FieldMorph.associateFields(@root.inEditMode, fetch_fields_url) if loadFields
        pictPromise = WordProcessor.Element.Content.Widget.PictureMorph.associatePictures(@root.inEditMode, fetch_pictures_url) if loadPictures

        $.when(fieldPromise, pictPromise).then (->
          # both AJAX calls have succeeded
          window.showDemoGuide() if window.showDemoGuide?
        ), (->
          # one of the AJAX calls has failed
        ), ->
          # always

        @root.setCaretFocus() if @root.inEditMode

  @init: (in_edit_mode=true, node$) ->
    if in_edit_mode
      @editBox = new WordProcessor.WPEditBox()


      @selectionMarker = []
      WordProcessor.Selection.registerAsSelectTool($("#selection_tool_xs"), @selectionMarker)
      WordProcessor.Selection.registerAsSelectTool($("#selection_tool_md"), @selectionMarker)

    @root = new WordProcessor.Element.Struct.DocMorph(in_edit_mode, node$);

    WordProcessor.Element.Content.Widget.FieldMorph.prepare();
    WordProcessor.Element.Content.Widget.PictureMorph.prepare();