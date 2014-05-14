window.WordProcessor.Element = {} if not window.WordProcessor.Element?

class WordProcessor.Element.StructMorph extends WordProcessor.Core.ElementMorph
  @__name__ = "WordProcessor.Element.StructMorph"
  @__class__: "element_structmorph"
  @__attribute__: "data-element-structmorph"

  constructor: (@inEditMode, @node$) ->
    @node$.addClass(WordProcessor.Element.StructMorph.__class__);
    @node$.attr(WordProcessor.Element.StructMorph.__attribute__, true);
    super(@inEditMode, @node$)

  firstContentMorph: ->
    morph = WordProcessor.Core.ElementMorph.getMorph(@node$.find(".#{WordProcessor.Core.ElementMorph.__class__}").first())
    if morph instanceof WordProcessor.Element.StructMorph
      morph.firstContentMorph()
    else if morph instanceof WordProcessor.Element.ContentMorph
      morph
    else
      null

  handleMouseDrag: (e) ->
    ## If no selection, user may be doing drag and drop for UI components such as Table resize
    if WordProcessor.Element.Struct.DocMorph.hasSelection()
      WordProcessor.Element.Struct.DocMorph.editBox.disableEdit()
      e.preventDefault();
      e.stopPropagation();

  handleUserClick : (e) ->
    @setCaretFocus()
    e.preventDefault();
    e.stopPropagation();

  setCaretFocus: ->
    return if not @inEditMode
    contentMorph = @firstContentMorph();
    contentMorph.setCaretFocus() if contentMorph?

  startVisit: (visitor, endContentMorph) ->

    endMorphNodePositionComparedToNode = @node$.get(0).compareDocumentPosition(endContentMorph.node$.get(0))

    if not (endMorphNodePositionComparedToNode is 0 or (endMorphNodePositionComparedToNode & Node.DOCUMENT_POSITION_FOLLOWING) or (endMorphNodePositionComparedToNode & (Node.DOCUMENT_POSITION_CONTAINED_BY | Node.DOCUMENT_POSITION_FOLLOWING)))
      ## Reached end content morph, return from here.
      return

    @visitSelf(visitor)
    @visitChildren(visitor, endContentMorph)
    @endVisit(visitor)
    @visitNeighbour(visitor, endContentMorph)

  visitChildren: (visitor, endContentMorph) ->
    startMorph = @firstElementMorph()

    return if not startMorph?

    startMorph.startVisit(visitor, endContentMorph)

class WordProcessor.Element.ContentMorph extends WordProcessor.Core.ElementMorph
  @__name__ = "WordProcessor.Element.ContentMorph"
  @__class__: "element_contentmorph"
  @__attribute__: "data-element-contentmorph"

  constructor: (@inEditMode, @node$) ->
    @node$.addClass(WordProcessor.Element.ContentMorph.__class__);
    @node$.attr(WordProcessor.Element.ContentMorph.__attribute__, true);
    super(@inEditMode, @node$)

  setCaretFocus: (textNode, offset=0) ->
    return if not @inEditMode
    if not textNode?
      textNode = @filterCurrentNodeForActionableNode()

    if not textNode?
      WordProcessor.Core.TextMorph.blank_space().prependTo(@node$)
      textNode = @node$.get(0).firstChild;

    @setFocusonTextNode(textNode, offset)

  setFocusonTextNode: (textNode, offset) ->
    return if not @inEditMode
    if not textNode?
      throw "Focused node has to be a valid text node. Shouldn't be null"

    offset = textNode.nodeValue.length if offset < 0
    WordProcessor.Element.Struct.DocMorph.editBox.attachATextNodeForEdit(textNode, offset)

  @getClosestContentMorphOfNode: (aTextNode)->
    contentNode$ = $(aTextNode).closest(".#{WordProcessor.Element.ContentMorph.__class__}");
    WordProcessor.Core.ElementMorph.getMorph(contentNode$)


  newEmptyInstance: ->
    return new @.constructor(@inEditMode)

  ##based on event.pageX fetch corresponding text node
  eventToTxtNode: (e) ->
    # target will always be an element node, since text node can't be a target.
    target = e.target

    clickXPosition = e.pageX
    clickYPosition = e.pageY - $(window).scrollTop()

    ## For caret focus, find text node nearer to left margin.
    focusTextNode = @findTextNodeAtMargin(clickXPosition, clickYPosition, target)
    if not focusTextNode?
      $(target).append("&nbsp;")
      focusTextNode = target.firstChild

    focusTextNode

  handleMouseDrag: (e) ->
    ## If no selection, user may be doing drag and drop for UI components such as Table resize
    if WordProcessor.Element.Struct.DocMorph.hasSelection()
      WordProcessor.Element.Struct.DocMorph.editBox.disableEdit()
      e.preventDefault();
      e.stopPropagation();

  handleUserClick : (e) ->
    focusTextNode = @eventToTxtNode(e)
    offset = @computeOffsetForTextNode(e.pageX, focusTextNode)
    selectionMarker = WordProcessor.Element.Struct.DocMorph.selectionMarker[0]

    if selectionMarker and selectionMarker.initSelection
      selectionMarker.addForSelection(focusTextNode, offset)
    else
      WordProcessor.Element.Struct.DocMorph.editBox.attachATextNodeForEdit(focusTextNode, offset)

    e.preventDefault();
    e.stopPropagation();

  computeOffsetForTextNode: (leftMargin, textNode) ->

    return 0 if not textNode?

    boundRange = document.createRange();
    boundRange.selectNodeContents(textNode);
    computedRect = boundRange.getBoundingClientRect();

    nodeTotalWidth = computedRect.left + computedRect.width

    return textNode.nodeValue.length if leftMargin > nodeTotalWidth


    offsetWidth = computedRect.width - (nodeTotalWidth - leftMargin)
    eachCharSize = computedRect.width / textNode.nodeValue.length;

    offsetCeil = Math.ceil(offsetWidth / eachCharSize)
    offsetFloor = Math.floor(offsetWidth / eachCharSize)

    marginCeil = computedRect.left + (offsetCeil * eachCharSize);
    marginFloor = computedRect.left + (offsetFloor * eachCharSize);

    diffCeil = Math.abs(marginCeil - leftMargin)
    diffFloor = Math.abs(marginFloor - leftMargin)

    if diffCeil <= diffFloor
      offset = offsetCeil
    else
      offset = offsetFloor

    return offset

  findTextNodeAtMargin: (clickXPosition, clickYPosition, currNode) =>

#    console.log("clickXPosition is #{clickXPosition}, clickYPosition is #{clickYPosition}")

    computedRect = WordProcessor.Util.computedRectangle(currNode)

    nodeTotalWidth = computedRect.left + computedRect.width
    nodeBottom = computedRect.bottom

    if nodeTotalWidth >= clickXPosition and nodeBottom >= clickYPosition
      return currNode if currNode.nodeType is Node.TEXT_NODE
      nextNode = currNode.firstChild
    else
      nextNode = currNode.nextSibling

    return @filterCurrentNodeForActionableNode(WordProcessor.WPCaret.DIRECTION_BEFORE, currNode) if not nextNode?
    @findTextNodeAtMargin(clickXPosition, clickYPosition, nextNode)

  setCaretFocusByMargin: (leftMargin, textNode=@filterCurrentNodeForActionableNode()) ->

    return if not @inEditMode

    if not textNode?
      @setCaretFocus()
      return

    if not textNode.nodeType is Node.TEXT_NODE
      throw "Node has to be of text node"

    boundRange = document.createRange();
    boundRange.selectNodeContents(textNode);
    computedRect = boundRange.getBoundingClientRect();

    nodeTotalWidth = computedRect.left + computedRect.width

    if nodeTotalWidth <=  leftMargin
      nextTextNode = @filterSiblingNodeForActionableNode(WordProcessor.WPCaret.DIRECTION_AFTER, textNode)
      if nextTextNode?
        @setCaretFocusByMargin(leftMargin, nextTextNode)
        return;
      else
        offset = textNode.nodeValue.length
    else
      offset = @computeOffsetForTextNode(leftMargin, textNode)

    @setFocusonTextNode(textNode, offset)

  # Search within a node and
  # retuns Text node
  # or
  # returns Widget Node if isWidgetNodeValid is set to true
  filterCurrentNodeForActionableNode : (direction=WordProcessor.WPCaret.DIRECTION_AFTER, thisNode=@node$.get(0), isNonCursorFocusableNodeValid=false) ->

    return null if not thisNode?

    if thisNode.nodeType is Node.TEXT_NODE
      return thisNode
    else if thisNode.nodeType is Node.ELEMENT_NODE
      morph = WordProcessor.Core.ElementMorph.getMorph($(thisNode))

      if morph? and (not morph.isCursorFocusable())
        return if isNonCursorFocusableNodeValid then thisNode else null

      children = thisNode.childNodes
      return null if children.length is 0

      if direction is WordProcessor.WPCaret.DIRECTION_AFTER
        start=0;
        end=children.length-1;
      else if direction is WordProcessor.WPCaret.DIRECTION_BEFORE
        start=children.length-1;
        end=0;

      for i in [start..end]
        rNode = @filterCurrentNodeForActionableNode(direction, children[i])
        return rNode if rNode?

  # Search sibling node and
  # retuns Text node
  # or
  # returns Widget Node if isWidgetNodeValid is set to true
  filterSiblingNodeForActionableNode: (direction=WordProcessor.WPCaret.DIRECTION_AFTER, afterThisNode, isNonCursorFocusableNodeValid=false)->

    return null if not afterThisNode?

    if direction is WordProcessor.WPCaret.DIRECTION_AFTER
      sib = afterThisNode.nextSibling
    else if direction is WordProcessor.WPCaret.DIRECTION_BEFORE
      sib = afterThisNode.previousSibling

    if not sib?
      parent = afterThisNode.parentNode
      return null if (not parent?) or parent is @node$.get(0)

      if direction is WordProcessor.WPCaret.DIRECTION_AFTER
        sib = parent.nextSibling
      else if direction is WordProcessor.WPCaret.DIRECTION_BEFORE
        sib = parent.previousSibling

    return null if not sib?

    rNode = @filterCurrentNodeForActionableNode(direction, sib, isNonCursorFocusableNodeValid)
    return rNode if rNode?

    @filterSiblingNodeForActionableNode(direction, sib, isNonCursorFocusableNodeValid)

  extractContentAfter: (node, offset) ->
    afterCaretRange = document.createRange()
    afterCaretRange.setStart node, offset
    afterCaretRange.setEndAfter @node$.get(0).lastChild
    extractedFragment = afterCaretRange.extractContents()

    ## node content might have changed after extraction.
    WordProcessor.Element.Struct.DocMorph.editBox.attachATextNodeForEdit(node, offset);
    extractedFragment

  extractContentBefore: (node, offset) ->
    beforeCaretRange = document.createRange()
    beforeCaretRange.setStartBefore @node$.get(0).firstChild
    beforeCaretRange.setEnd node, offset
    extractedFragment = beforeCaretRange.extractContents()

    ## node content might have changed after extraction.
    WordProcessor.Element.Struct.DocMorph.editBox.attachATextNodeForEdit(node, offset);
    extractedFragment

  keypress: (e, focusedTextNode, cursorOffset) =>
    key_code = e.which || e.charCode || 0;
    console.log("Keypress at #{@.constructor.__name__}, with id #{@id}, and key is #{key_code}, textNode is #{focusedTextNode}, cursorOffset is #{cursorOffset}");

  keyup: (e, focusedTextNode, cursorOffset) =>
    key_code = e.keyCode || 0;
    console.log("Keyup at #{@.constructor.__name__}, with id #{@id}, and key is #{key_code}, textNode is #{focusedTextNode}, cursorOffset is #{cursorOffset}");

  keydown: (e, focusedTextNode, cursorOffset) =>
    key_code = e.keyCode || 0;
    console.log("Keydown at #{@.constructor.__name__}, with id #{@id}, and key is #{key_code}, textNode is #{focusedTextNode}, cursorOffset is #{cursorOffset}");

    if key_code is WordProcessor.KEY_BOARD.KEY_RETURN
      @handleReturn(e, focusedTextNode, cursorOffset)
    else if key_code is WordProcessor.KEY_BOARD.KEY_UP or key_code is WordProcessor.KEY_BOARD.KEY_DOWN
      @_handleKeyUpDownNavigation(e, focusedTextNode, key_code, cursorOffset)
    else if key_code is WordProcessor.KEY_BOARD.KEY_RIGHT and focusedTextNode.nodeValue.length is cursorOffset
      @_handleKeyRightNavigation(e, focusedTextNode, key_code, cursorOffset)
    else if (key_code is WordProcessor.KEY_BOARD.KEY_LEFT and cursorOffset is 0)
      @_handleKeyLeftNavigation(e, focusedTextNode, key_code, cursorOffset)
    else if key_code is WordProcessor.KEY_BOARD.KEY_BACKSPACE and cursorOffset is 0
      @_handleBackspaceWhenCaretAtStart(e, focusedTextNode, key_code, cursorOffset)
    else if key_code is WordProcessor.KEY_BOARD.KEY_DELETE and focusedTextNode.nodeValue.length is cursorOffset
      @_handleDeleteWhenCaretAtEnd(e, focusedTextNode, key_code, cursorOffset)

  _handleDeleteWhenCaretAtEnd: (e, focusedTextNode, keyCode, cursorOffset) ->
    nextNode = @filterSiblingNodeForActionableNode(WordProcessor.WPCaret.DIRECTION_AFTER, focusedTextNode, true)
    if nextNode?
      if nextNode.nodeType is Node.TEXT_NODE
        @setCaretFocus(nextNode)
      else
        morph = WordProcessor.Core.ElementMorph.getMorph($(nextNode))
        if morph? and confirm(morph.constructor.removeMsg)
          @node$.get(0).removeChild(morph.node$.get(0));
        e.preventDefault();
    else
      @mergeWithNextSibling(e)

  _handleBackspaceWhenCaretAtStart: (e, focusedTextNode, keyCode, cursorOffset) ->
    nextNode = @filterSiblingNodeForActionableNode(WordProcessor.WPCaret.DIRECTION_BEFORE, focusedTextNode, true)
    if nextNode?
      if nextNode.nodeType is Node.TEXT_NODE
        @setCaretFocus(nextNode, -1)
      else
        morph = WordProcessor.Core.ElementMorph.getMorph($(nextNode))
        if morph? and confirm(morph.constructor.removeMsg)
          @node$.get(0).removeChild(morph.node$.get(0));
        e.preventDefault();
    else
      @mergeWithPrevSibling(e)

  _handleKeyRightNavigation: (e, focusedTextNode, keyCode, cursorOffset) ->
    nextTextNode = @filterSiblingNodeForActionableNode(WordProcessor.WPCaret.DIRECTION_AFTER, focusedTextNode)
    if nextTextNode?
      boundRangeNextTextNode = document.createRange();
      boundRangeNextTextNode.selectNodeContents(focusedTextNode);
      computedRectCurrTextNode = boundRangeNextTextNode.getBoundingClientRect();

      boundRangeNextTextNode = document.createRange();
      boundRangeNextTextNode.selectNodeContents(nextTextNode);
      computedRectNextTextNode = boundRangeNextTextNode.getBoundingClientRect();

      positionLeftDiff = (computedRectCurrTextNode.left + computedRectCurrTextNode.width) - computedRectNextTextNode.left;
      if positionLeftDiff is 0
        @setCaretFocus(nextTextNode, 1)
      else
        @setCaretFocus(nextTextNode)
    else
      ## Next line first text node
      next = @node$.next(".#{WordProcessor.Core.ElementMorph.__class__}")
      nextMorph = WordProcessor.Core.ElementMorph.getMorph(next) if next?
      if nextMorph?
        firstTextNode  = nextMorph.filterCurrentNodeForActionableNode(WordProcessor.WPCaret.DIRECTION_AFTER)
        nextMorph.setFocusonTextNode(firstTextNode) if firstTextNode?
    e.preventDefault();

  _handleKeyLeftNavigation: (e, focusedTextNode, keyCode, cursorOffset) ->
    nextTextNode = @filterSiblingNodeForActionableNode(WordProcessor.WPCaret.DIRECTION_BEFORE, focusedTextNode)
    if nextTextNode?
      boundRangeNextTextNode = document.createRange();
      boundRangeNextTextNode.selectNodeContents(focusedTextNode);
      computedRectCurrTextNode = boundRangeNextTextNode.getBoundingClientRect();

      boundRangeNextTextNode = document.createRange();
      boundRangeNextTextNode.selectNodeContents(nextTextNode);
      computedRectNextTextNode = boundRangeNextTextNode.getBoundingClientRect();

      positionLeftDiff = (computedRectNextTextNode.left + computedRectNextTextNode.width) - computedRectCurrTextNode.left;
      if positionLeftDiff is 0
        @setCaretFocus(nextTextNode, nextTextNode.nodeValue.length-1)
      else
        @setCaretFocus(nextTextNode, -1)
    else
      ## Previous line last text node
      next = @node$.prev(".#{WordProcessor.Core.ElementMorph.__class__}")
      nextMorph = WordProcessor.Core.ElementMorph.getMorph(next) if next?
      if nextMorph?
        firstTextNode  = nextMorph.filterCurrentNodeForActionableNode(WordProcessor.WPCaret.DIRECTION_BEFORE)
        nextMorph.setFocusonTextNode(firstTextNode, -1) if firstTextNode?
    e.preventDefault();



  _handleKeyUpDownNavigation: (e, focusedTextNode, keyCode, cursorOffset) ->
    boundRange = document.createRange();
    boundRange.selectNodeContents(focusedTextNode);
    computedRect = boundRange.getBoundingClientRect();
    eachCharSize = computedRect.width / focusedTextNode.nodeValue.length;
    leftMargin = computedRect.left + (eachCharSize * cursorOffset)

    parent = $(focusedTextNode).closest(".#{WordProcessor.Core.ElementMorph.__class__}")

    if keyCode is WordProcessor.KEY_BOARD.KEY_UP
      next = parent.prev(".#{WordProcessor.Core.ElementMorph.__class__}")
    else if keyCode is WordProcessor.KEY_BOARD.KEY_DOWN
      next = parent.next(".#{WordProcessor.Core.ElementMorph.__class__}")

    nextMorph = WordProcessor.Core.ElementMorph.getMorph(next) if next?
    nextMorph.setCaretFocusByMargin(leftMargin) if nextMorph?

    e.preventDefault();

  mergeWithPrevSibling: (e) =>
    prevSibNode = @node$.get(0).previousSibling
    prevSib = WordProcessor.Core.ElementMorph.getMorph($(prevSibNode))

    if prevSib && prevSib instanceof @.constructor
      prevSib.mergeWith(this)

    e.preventDefault()

  mergeWithNextSibling: (e) =>
    nextSibNode = @node$.get(0).nextSibling
    nextSib = WordProcessor.Core.ElementMorph.getMorph($(nextSibNode))

    if nextSib && nextSib instanceof @.constructor
      @mergeWith(nextSib)

    e.preventDefault()

  handleReturn: (e, focusedTextNode, cursorOffset) =>
    afterCaretContent = @extractContentAfter(focusedTextNode, cursorOffset)

    ## Create a new line and add it after current line.
    newMorph = @newEmptyInstance()
    newMorph.appendContent(afterCaretContent)
    newMorph.node$.insertAfter(@.node$);
    newMorph.setCaretFocus();

    e.preventDefault();

  mergeWith: (anotherMorph) ->
    WordProcessor.Style.ContentElementStyleMorph.removeStyle(anotherMorph)
    anotherMorphNode = anotherMorph.node$.get(0)

    r = document.createRange()
    r.setStartBefore anotherMorphNode.firstChild
    r.setEndAfter anotherMorphNode.lastChild

    extractedContent = r.extractContents()
    @node$.append(extractedContent)
    anotherMorph.node$.remove()

  ## Used when user performs copy (or) cut ##
  fetchSelectionAsMorph: (doCut = true) =>
    rangeOfSelection = @getRangeOfSelection(@node$)

    if (rangeOfSelection is undefined) or (rangeOfSelection is null)
      return null

    sRange = rangeOfSelection["range"]

    if (sRange is undefined) or (sRange is null)
      return null

    if doCut
      fragment = sRange.extractContents()
    else
      fragment = sRange.cloneContents()

    newMorph = @newEmptyInstance()
    newMorph.node$.append(fragment)

    return {"isFullSelection" : rangeOfSelection["isFullSelection"], "morph" : newMorph}


  startVisit: (visitor, endContentMorph) ->

    endMorphNodePositionComparedToNode = @node$.get(0).compareDocumentPosition(endContentMorph.node$.get(0))

    if not (endMorphNodePositionComparedToNode is 0 or (endMorphNodePositionComparedToNode & Node.DOCUMENT_POSITION_FOLLOWING) or (endMorphNodePositionComparedToNode & (Node.DOCUMENT_POSITION_CONTAINED_BY | Node.DOCUMENT_POSITION_FOLLOWING)))
      ## Reached end content morph, return from here.
      return

    @visitSelf(visitor)
    @endVisit(visitor)
    @visitNeighbour(visitor, endContentMorph)



