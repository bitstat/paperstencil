window.WordProcessor.Element.Struct = {} if not window.WordProcessor.Element.Struct?

class WordProcessor.Element.Struct.TableCellMorph extends WordProcessor.Element.StructMorph

  @__name__ = "WordProcessor.Element.Struct.TableCellMorph"
  WordProcessor.Core.MorphMap[@__name__] = @

  @__class__: "element_struct_tablecellmorph"
  @__attribute__: "data-element-struct-tablecellmorph"

  constructor: (@inEditMode, @rowMorph, @node$, @canResize=true) ->
    @node$ = $("<td>") if not @node$? or not @node$.get(0)?
    @node$.addClass(WordProcessor.Element.Struct.TableCellMorph.__class__)
    super(@inEditMode, @node$)

    ## Resize of cell will not work in FFx
    ## FFX issue - http://bugs.jqueryui.com/ticket/8120
    ## https://bugzilla.mozilla.org/show_bug.cgi?id=63895
    @makeResizable()

  ## This method is called when user select option on context menu ##
  handleContextOption: (key) =>
    rowNode$ = @node$.closest(".#{WordProcessor.Element.Struct.TableRowMorph.__class__}")
    rowMorph = WordProcessor.Core.ElementMorph.getMorph(rowNode$)
    rowMorph.handleContextOption(key, @)

  makeResizable: ->
    @node$.resizable({handles: "e"}) if @inEditMode and @canResize

  newEmptyInstance:() ->
    new @.constructor(@rowMorph, null, false)

  accept: (visitor, endVisit=false) =>
    if endVisit
      visitor.endVisitTableCell(@)
    else
      visitor.startVisitTableCell(@)

  handleDleteWhenCaretAtEnd: (e) =>
    e.preventDefault()

  handleBackspaceWhenCaretAtStart: (e) =>
    e.preventDefault()

  contentAsMorphs: ->
    morphs = []
    for childNode in @node$.get(0).childNodes
      childNodeMorph = WordProcessor.Core.ElementMorph.getMorph($(childNode))
      morphs.push(childNodeMorph) if childNodeMorph?
    morphs

  keyup: (e) =>
    key_code = e.keyCode || 0;
    console.log("Keydown at #{@styleClass()}, with id #{@id}, and key is #{key_code}");

    if key_code is WordProcessor.KEY_BOARD.KEY_DELETE || key_code is WordProcessor.KEY_BOARD.KEY_BACKSPACE
      ## reenable resize handle
      $(".ui-resizable-handle", @node$).show()

    super(e)

  keydown: (e) =>
    key_code = e.keyCode || 0;
    console.log("Keydown at #{@styleClass()}, with id #{@id}, and key is #{key_code}");

    if key_code is WordProcessor.KEY_BOARD.KEY_DELETE || key_code is WordProcessor.KEY_BOARD.KEY_BACKSPACE
      ## make sure resize handles aren't deleted
      $(".ui-resizable-handle", @node$).hide()

    super(e)

  toJSONStruct: (fields=[], pictures=[]) ->

    try
      @node$.resizable("destroy")
    catch

    struct = super(fields, pictures)
    meta = struct['design_struct']['meta']
    $.extend(meta, {width: (@node$.width()/@rowMorph.tableMorph.node$.width() * 100)})

    @makeResizable()

    struct

  @registerContextMenu: ->
    $(document).ready ->
      $.contextMenu
        selector: ".#{WordProcessor.Element.Struct.TableCellMorph.__class__}"
        callback: (key, options) ->
          triggerTableCell$ = options.$trigger
          triggerMorph = WordProcessor.Core.ElementMorph.getMorph(triggerTableCell$)
          triggerMorph.handleContextOption(key)

        items: WordProcessor.Element.Struct.TableMorph.CONTEXT_MENU_OPTIONS
        zIndex: 1036




WordProcessor.Element.Struct.TableCellMorph.registerContextMenu()
