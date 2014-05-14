class WordProcessor.WPDummyCaret

  constructor: () ->
    @node$ = $("<span style='font-family: courier,fixed;font-size: 15px;color: #111111;position: absolute;'><img src='data:image/gif;base64,R0lGODlhAQAQAIABAAAAAP///yH/C05FVFNDQVBFMi4wAwEAAAAh/hpDcmVhdGVkIGJ5IFB1cHB5T25UaGVSYWRpbwAh+QQJMgABACwAAAAAAQAQAAACBIyPGQUAIfkECTIAAQAsAAAAAAEAEAAAAgSEjwkFADs='/></span>");

  setPosition : (left, top) ->
    @node$.css("left", left);
    @node$.css("top", top);

  hide: ->
    @node$.hide()

  show: ->
    @node$.show()

class WordProcessor.WPEditBox

  constructor: () ->
    @nodeContainer$ = $("<div id='editboxContainer' style='overflow: hidden; position: absolute; padding: 0; outline: none; font-size: 10px;width: 0px; height: 5em;'></div>")
    @node$ = $("<input type='text' style='position: absolute'/>");
    @dummyCaret = new WordProcessor.WPDummyCaret();
    @doSync = true;

    @nodeContainer$.append(@node$)
    $("body").append(@nodeContainer$);
    $("body").append(@dummyCaret.node$);

    @_registerForKeyEvents();
    @_registerForBlur();
    @syncEditBoxAndTextNode();

    ## Dot keypress cache ##
    @dotKeyCache = []


  enableSync: () ->
    @doSync = true

  disableSync: () ->
    @doSync = false

  disableEdit: ()->
    @disableSync()
    @dummyCaret.hide()

  syncNow: ()->
    txtNode = @attachedTextNode()
    if @doSync and txtNode?
      tVal = @node$.val();
      tVal = tVal.replace(/\s/g, String.fromCharCode(160));
      txtNode.nodeValue = tVal;
      @_moveVisibleCurosr();


  _registerForBlur: () ->
    @node$.blur (e) =>
      @disableEdit()

  _moveVisibleCurosr: () ->
    txtNode = @attachedTextNode()
    return if not txtNode?

    boundRange = document.createRange();
    boundRange.selectNodeContents(txtNode);

    computedRect = boundRange.getBoundingClientRect();
    length = txtNode.nodeValue.length;

    if length is 0
      prevSibNode = txtNode.previousSibling
      if prevSibNode?
        computedRect = WordProcessor.Util.computedRectangle(prevSibNode)
        left = computedRect.left + computedRect.width
        top = computedRect.top
      else
        parentNode = txtNode.parentNode
        computedRect = WordProcessor.Util.computedRectangle(parentNode)
        left = computedRect.left
        top = computedRect.top
    else
      eachCharSize = (computedRect.width / length);
      position = @getCaretPosition();
      left = computedRect.left + (eachCharSize * position)
      top = computedRect.top

    left = left + window.pageXOffset
    top = top + window.pageYOffset

    @dummyCaret.setPosition(left, top)
    @nodeContainer$.css("top", top)
    if not WordProcessor.Util.isElementInViewport(@nodeContainer$.get(0))
      @nodeContainer$.get(0).scrollIntoView(false);

  setCaretPosition: (pos) ->
    node = @node$.get(0);
    if node.setSelectionRange
      node.focus()
      node.setSelectionRange pos, pos
    else if node.createTextRange
      range = node.createTextRange()
      range.collapse true
      range.moveEnd "character", pos
      range.moveStart "character", pos
      range.select()

    @_moveVisibleCurosr()
    @dummyCaret.show()
    return

  getCaretPosition: ->

    node = @node$.get(0);

    # Initialize
    iCaretPos = 0

    # IE Support
    if document.selection

      # Set focus on the element
      node.focus()

      # To get cursor position, get empty selection range
      oSel = document.selection.createRange()

      # Move selection start to 0 position
      oSel.moveStart "character", -node.value.length

      # The caret position is selection length
      iCaretPos = oSel.text.length

      # Firefox support
    else iCaretPos = node.selectionStart  if node.selectionStart or node.selectionStart is "0"

    # Return results
    iCaretPos

  attachATextNodeForEdit: (sc, so=0) ->

    return if not sc?

    # If cursor can't be focused, ignore text node
    contentMorph = WordProcessor.Element.ContentMorph.getClosestContentMorphOfNode(sc)
    return if not contentMorph.isCursorFocusable()

    @disableEdit()
    if not sc?
      range = window.getSelection().getRangeAt(0);
      sc = range.startContainer;
      so = range.startOffset;

    @node$.data("textNodeToEdit", {sc: sc, so : so });
    @node$.val(sc.nodeValue);
    @setCaretPosition(so);



  attachedTextNode: () =>
    txtMap = @node$.data("textNodeToEdit")
    if txtMap?
      txtMap.sc;

  contentMorphOfattachedTextNode: ->
    WordProcessor.Element.ContentMorph.getClosestContentMorphOfNode(@attachedTextNode());

  _registerForKeyEvents: ->

    @node$.keyup (e) =>
      @disableSync()
      focusedMorph = @contentMorphOfattachedTextNode();
      focusedMorph.keyup(e, @attachedTextNode(), @getCaretPosition()) if focusedMorph?

    @node$.keydown (e) =>
      @enableSync()
      focusedMorph = @contentMorphOfattachedTextNode();
      focusedMorph.keydown(e, @attachedTextNode(), @getCaretPosition()) if focusedMorph?

    @node$.keypress (e) =>
      focusedMorph = @contentMorphOfattachedTextNode()

      key_code = e.which || e.charCode || 0;

      if key_code is WordProcessor.KEY_BOARD.KEY_DOT

        # Handle dot key
        lastDotEvent = @dotKeyCache.slice(-1)[0]

        if not lastDotEvent or (e.timeStamp - lastDotEvent.timeStamp) > 3000
          @dotKeyCache = []
          @dotKeyCache.push e
          return

        @dotKeyCache.push e
        if @dotKeyCache.length is 3

          nodeVal = @node$.val();

          currPosition = @getCaretPosition()
          newPosition = currPosition - 2

          # console.log(" currPosition #{currPosition}, newPosition #{newPosition}");

          @node$.val(nodeVal.substring(0, newPosition) + nodeVal.substring(currPosition, nodeVal.length));
          @setCaretPosition(newPosition);
          @syncNow();

          WordProcessor.Element.Content.Widget.FieldMorph.insertFieldAtCaret(focusedMorph, @attachedTextNode(), newPosition) if focusedMorph

          e.preventDefault()
          @dotKeyCache = []
      else
        focusedMorph.keypress(e, @attachedTextNode(), @getCaretPosition()) if focusedMorph


  syncEditBoxAndTextNode: =>

    if requestAnimationFrame?
      requestAnimationFrame(@syncEditBoxAndTextNode)
    else
      setTimeout(@syncEditBoxAndTextNode, 40);

    @syncNow()


