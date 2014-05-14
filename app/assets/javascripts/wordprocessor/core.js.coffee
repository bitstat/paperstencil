# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.WordProcessor = {} if not window.WordProcessor?
window.WordProcessor.Core = {} if not window.WordProcessor.Core?

WordProcessor.Visitor = {} if not window.WordProcessor.Visitor?
WordProcessor.Style = {} if not window.WordProcessor.Style?
WordProcessor.Style.Klasses = {} if not window.WordProcessor.Style.Klasses?

###
  String.endsWith only available in Firefox. Hence declare it, if not found.
###

if typeof String::endsWith isnt "function"
  String::endsWith = (suffix) ->
    @indexOf(suffix, @length - suffix.length) isnt -1

window.WordProcessor.KEY_BOARD = {
  KEY_BACKSPACE: 8,
  KEY_TAB: 9,
  KEY_RETURN: 13,
  KEY_ESC: 27,
  KEY_LEFT: 37,
  KEY_UP: 38,
  KEY_RIGHT: 39,
  KEY_DOWN: 40,
  KEY_DELETE: 46,
  KEY_HOME: 36,
  KEY_END: 35,
  KEY_PAGEUP: 33,
  KEY_PAGEDOWN: 34,
  KEY_INSERT: 45,
  KEY_DOT: 46
}

WordProcessor.Core.MorphMap = {}

class WordProcessor.Core.BaseMorph
  constructor: () ->

class WordProcessor.Core.TextMorph extends WordProcessor.Core.BaseMorph

  constructor: (content) ->
    content = '' if not content
    @node$ = $(document.createTextNode(content))
    super

  appendTo: (node$) ->
    node$.append(@node$)

  prependTo: (node$) ->
    node$.prepend(@node$)

  insertAfter: (node$) ->
    @node$.insertAfter(node$)

  insertBefore: (node$) ->
    @node$.insertBefore(node$)

  @create: (content = null) ->
    new WordProcessor.Core.TextMorph(content)

  @empty: ->
    new WordProcessor.Core.TextMorph(null);

  @blank_space: ->
    new WordProcessor.Core.TextMorph(String.fromCharCode(160))

class WordProcessor.Core.ElementMorph extends WordProcessor.Util.mixOf WordProcessor.Core.BaseMorph, WordProcessor.Mixin.SerializationRelated
  @__name__ = "WordProcessor.Core.ElementMorph"
  @__class__: "elementmorph"
  @__attribute__: "data-elementmorph"
  @__attached__: "attched_morph"

  constructor: (@inEditMode, @node$) ->

#    @id = new Date().getTime()
    @id = $().nextNumber()
    @node$.attr("id", @id)

    @node$.addClass(WordProcessor.Core.ElementMorph.__class__);
    @node$.attr(WordProcessor.Core.ElementMorph.__attribute__, true);
    @node$.data(WordProcessor.Core.ElementMorph.__attached__, this);

    if @inEditMode
      @convertClickToCaretFocus()

    super

  convertClickToCaretFocus: ->
    @node$.click (e) =>
      e.preventDefault();
      e.stopPropagation();

    clickXPosition = 0
    clickYPosition = 0

    @node$.mousedown (e) =>
      clickXPosition = e.pageX
      clickYPosition = e.pageY

    @node$.mouseup (e) =>

      ## Mouse down was at different position and mouse up was at different position, that means user would have made text selection
      if (clickXPosition isnt e.pageX) and (clickYPosition isnt e.pageY)
        @handleMouseDrag(e)
      else
        @handleUserClick(e)

  handleMouseDrag: (e) ->
    throw "handleMouseDrag should be implemented by sub class"

  handleUserClick : (e) ->
    throw "handleUserClick should be implemented by sub class"

  isCursorFocusable: () ->
    true

  ## Can be of struct morph or content morph
  firstElementMorph: ->
    WordProcessor.Core.ElementMorph.getMorph($(@node$.get(0).querySelector(".#{WordProcessor.Core.ElementMorph.__class__}")))

  ## Can be of struct morph or content morph
  lastElementMorph: (node$=@node$) ->
    lastElementMorph = null
    return lastElementMorph if not node$.get(0)?

    childrenNodes = node$.get(0).childNodes

    for i in [childrenNodes.length - 1..0] by -1
      child$ = $(childrenNodes[i])
      lastElementMorph = WordProcessor.Core.ElementMorph.getMorph(child$)
      lastElementMorph = @lastElementMorph(child$) if not lastElementMorph?
      break if lastElementMorph?

    lastElementMorph

  ## This methos will be overridden by sub classes.
  @newEmptyInstanceFromDesign: (inEditMode, design_struct, parent_morph) ->
    new @(inEditMode)

  parentMorph: ()->
    parentNode$ = $(@node$.get(0).parentNode).closest(".#{WordProcessor.Core.ElementMorph.__class__}")
    WordProcessor.Core.ElementMorph.getMorph(parentNode$)

  getRangeOfSelection : (node$=@node$) ->
    node = node$.get(0)

    isFullSelection = false
    sRange = null

    return {"isFullSelection" : isFullSelection, "range" : sRange } if not node.firstChild?

    selection = window.getSelection()
    range = selection.getRangeAt(0)

    startNode = range.startContainer
    startOffset = range.startOffset

    endNode = range.endContainer
    endOffset = range.endOffset

    ## set aPartlyContained to false
    if WordProcessor.Util.containsNodeInSelection(selection, node, false)
      ## Full selection of container
      sRange = document.createRange()
      sRange.setStartBefore(node.firstChild)
      sRange.setEndAfter(node.lastChild)
      isFullSelection = true

    else if WordProcessor.Util.containsNodeInSelection(selection, node, true)
      ## Partial selection of container
      sRange = document.createRange()

      startNodeCompareWithFirstChild = node.firstChild.compareDocumentPosition(startNode)
      endNodeCompareWithLastChild = node.lastChild.compareDocumentPosition(endNode)

      isStartNodeIsBeforeFirstChild = (startNodeCompareWithFirstChild is Node.DOCUMENT_POSITION_PRECEDING) or (startNodeCompareWithFirstChild is (Node.DOCUMENT_POSITION_CONTAINED_BY | Node.DOCUMENT_POSITION_PRECEDING))
      isEndNodeIsAfterLastChild = (endNodeCompareWithLastChild is Node.DOCUMENT_POSITION_FOLLOWING) or (endNodeCompareWithLastChild is (Node.DOCUMENT_POSITION_CONTAINED_BY | Node.DOCUMENT_POSITION_FOLLOWING))

      if isStartNodeIsBeforeFirstChild
        sRange.setStartBefore(node.firstChild)
      else
        sRange.setStart(startNode, startOffset)

      if isEndNodeIsAfterLastChild
        sRange.setEndAfter(node.lastChild)
      else
        sRange.setEnd(endNode, endOffset)

    return {"isFullSelection" : isFullSelection, "range" : sRange }

  visitNeighbour: (visitor, endMorph) ->
    nextSibMorph = WordProcessor.Core.ElementMorph.getMorph(@node$.next())
    if nextSibMorph?
      nextSibMorph.startVisit(visitor, endMorph)

  visitSelf: (visitor) ->
#    console.log("Start visiting")
#    console.log(@node$.get(0))
    @accept(visitor)

  endVisit: (visitor) ->
#    console.log("end visiting")
#    console.log(@node$.get(0))
    @accept(visitor, true)

  accept: (visitor, endVisit=false) =>
    throw "cant accept visitor on WordProcessor.Core.ElementMorph, should be implemented by sub class"

  @getMorph: (node$) ->
    node$.data(WordProcessor.Core.ElementMorph.__attached__);

class WordProcessor.Core.UnknownElementMorph extends WordProcessor.Util.mixOf WordProcessor.Core.BaseMorph, WordProcessor.Mixin.SerializationRelated

  @__name__ = "WordProcessor.Core.UnknownElementMorph"

  WordProcessor.Core.MorphMap[@__name__] = @

  constructor: (@inEditMode, @node$) ->
    super(@inEditMode, @node$)


  addExtraMetaData: (design) ->
    node = @node$.get(0)
    meta = design['design_struct']['meta']
    $.extend(meta, { node_name: node.nodeName, attributes: {} })
    if node.hasAttributes and node.hasAttributes()
      for attr in node.attributes
        meta["attributes"][attr.name]  = attr.value

    design

  @newEmptyInstanceFromDesign: (inEditMode, design_struct, parent_morph) ->
    meta = design_struct['meta']
    nodeNew$ = $("<#{meta['node_name']}>")
    for name, value of meta["attributes"]
      nodeNew$.attr(name, value)
    new @(inEditMode, nodeNew$)