window.WordProcessor = {} if not window.WordProcessor?
class WordProcessor.Util

  ###
    mixOf was not part of coffeescript script compilet that comewith Rails 4.0. Hence declare it, if not found.
  ###
  @mixOf = (base, mixins...) ->
    class Mixed extends base
    for mixin in mixins by -1 #earlier mixins override later ones
      for name, method of mixin::
        Mixed::[name] = method
    Mixed

  @highlightNode: (node$) ->
    node$ = $(window.getSelection().anchorNode) if not node$? or not node$.get(0)?
    if node$.get(0).nodeType is Node.TEXT_NODE
      span$ = $("span")
      span$.css({'backgroundColor': 'yellow'});
      node$.wrap span$
    else
      node$.css({'outline': '3px solid #f00'});

  @setFocusOnTextNode: (txtNode, position) ->
    return false if not txtNode? or not txtNode.nodeType is Node.TEXT_NODE

    range = document.createRange()
    range.setStart txtNode, 0

    if position?
      position = 0
    else if position is -1 || position > txtNode.nodeValue.length
      position = txtNode.nodeValue.length

    range.setEnd txtNode, position
    range.collapse false
    selection = window.getSelection()
    selection.removeAllRanges()
    selection.addRange range

  @normalizeEmptyNode: (node$) ->
    node$.html "&nbsp;"  if @isEmptyNode(node$.get(0))

  @isEmptyNode: (node, chkEmptyTxtNodeFunction = @isEmptyTxtNode) ->
    return chkEmptyTxtNodeFunction(node)  if node.nodeType is Node.TEXT_NODE
    if node.nodeType is Node.ELEMENT_NODE
      if node.nodeName is "IMG" or node.nodeName is "INPUT" or node.nodeName is "CANVAS" or node.nodeName is "SVG"
        false
      else
        isEmpty = true
        for childNode in node.childNodes
          continue  if childNode.nodeName is "BR" || childNode.nodeName is "HR"
          isEmpty = @isEmptyNode(childNode)
          return isEmpty  if isEmpty is false
        isEmpty

  @isEmptyTxtNode: (node) ->
    node.nodeValue.trim() is ""

  @removeEmptyNodes : (node, chkEmptyTxtNodeFunction=@isEmptyTxtNode) ->
    return if not node?
    childNode = node.firstChild
    while childNode
      oldChildNode = childNode
      childNode = childNode.nextSibling
      node.removeChild(oldChildNode) if @isEmptyNode(oldChildNode, chkEmptyTxtNodeFunction)


  @getAllEffectivelyContainedNodes : (range, condition) ->
    if typeof condition is "undefined"
      condition = ->
        true
    node = range.startContainer
    node = node.parentNode while @isEffectivelyContained(node.parentNode, range)
    stop = @nextNodeDescendants(range.endContainer)
    nodeList = []
    while @isBefore(node, stop)
      nodeList.push node  if condition(node) and @isEffectivelyContained(node, range)
      node = @nextNode(node)
    nodeList

  @nextNode: (node) ->
    return node.firstChild  if node.hasChildNodes()
    @nextNodeDescendants node

  @previousNode: (node) ->
    if node.previousSibling
      node = node.previousSibling
      node = node.lastChild  while node.hasChildNodes()
      return node
    return node.parentNode  if node.parentNode and node.parentNode.nodeType is Node.ELEMENT_NODE
    null

  @nextNodeDescendants: (node) ->
    node = node.parentNode  while node and not node.nextSibling
    return null  unless node
    node.nextSibling

  ###
  Returns true if ancestor is an ancestor of descendant, false otherwise.
  ###
  @isAncestor: (ancestor, descendant) ->
    ancestor and descendant and Boolean(ancestor.compareDocumentPosition(descendant) & Node.DOCUMENT_POSITION_CONTAINED_BY)

  ###
  Returns true if ancestor is an ancestor of or equal to descendant, false
  otherwise.
  ###
  @isAncestorContainer: (ancestor, descendant) ->
    (ancestor or descendant) and (ancestor is descendant or @isAncestor(ancestor, descendant))

  ###
  Returns true if descendant is a descendant of ancestor, false otherwise.
  ###
  @isDescendant : (descendant, ancestor) ->
    ancestor and descendant and Boolean(ancestor.compareDocumentPosition(descendant) & Node.DOCUMENT_POSITION_CONTAINED_BY)

  ###
  Returns true if node1 is before node2 in tree order, false otherwise.
  ###
  @isBefore : (node1, node2) ->
    Boolean node1.compareDocumentPosition(node2) & Node.DOCUMENT_POSITION_FOLLOWING

  ###
  Returns true if node1 is after node2 in tree order, false otherwise.
  ###
  @isAfter : (node1, node2) ->
    Boolean node1.compareDocumentPosition(node2) & Node.DOCUMENT_POSITION_PRECEDING

  @getAncestors : (node) ->
    ancestors = []
    while node.parentNode
      ancestors.unshift node.parentNode
      node = node.parentNode
    ancestors

  @getInclusiveAncestors : (node) ->
    @getAncestors(node).concat node

  @getDescendants : (node) ->
    descendants = []
    stop = @nextNodeDescendants(node)
    descendants.push node  while (node = @nextNode(node)) and node isnt stop
    descendants

  @getInclusiveDescendants : (node) ->
    [node].concat @getDescendants(node)

  @getNodeLength : (node) ->
    switch node.nodeType
      when Node.PROCESSING_INSTRUCTION_NODE, Node.DOCUMENT_TYPE_NODE
        0
      when Node.TEXT_NODE, Node.COMMENT_NODE
        node.length
      else
        node.childNodes.length

  @getFurthestAncestor : (node) ->
    root = node
    root = root.parentNode  while root.parentNode?
    root

  ###
  The position of two boundary points relative to one another, as defined by
  DOM Range.
  ###
  @getPosition : (nodeA, offsetA, nodeB, offsetB) ->

    # "If node A is the same as node B, return equal if offset A equals offset
    # B, before if offset A is less than offset B, and after if offset A is
    # greater than offset B."
    if nodeA is nodeB
      return "equal"  if offsetA is offsetB
      return "before"  if offsetA < offsetB
      return "after"  if offsetA > offsetB

    # "If node A is after node B in tree order, compute the position of (node
    # B, offset B) relative to (node A, offset A). If it is before, return
    # after. If it is after, return before."
    if nodeB.compareDocumentPosition(nodeA) & Node.DOCUMENT_POSITION_FOLLOWING
      pos = @getPosition(nodeB, offsetB, nodeA, offsetA)
      return "after"  if pos is "before"
      return "before"  if pos is "after"

    # "If node A is an ancestor of node B:"
    if nodeB.compareDocumentPosition(nodeA) & Node.DOCUMENT_POSITION_CONTAINS

      # "Let child equal node B."
      child = nodeB

      # "While child is not a child of node A, set child to its parent."
      child = child.parentNode  until child.parentNode is nodeA

      # "If the index of child is less than offset A, return after."
      return "after"  if @getNodeIndex(child) < offsetA

    # "Return before."
    "before"

  @getNodeIndex : (node) ->
    ret = 0
    while node.previousSibling
      ret++
      node = node.previousSibling
    ret

  ###
  "contained" as defined by DOM Range: "A Node node is contained in a range
  range if node's furthest ancestor is the same as range's root, and (node, 0)
  is after range's start, and (node, length of node) is before range's end."

  returns true only if node is inside range
  ###
  @isContained : (node, range) ->
    pos1 = @getPosition(node, 0, range.startContainer, range.startOffset)
    pos2 = @getPosition(node, @getNodeLength(node), range.endContainer, range.endOffset)
    @getFurthestAncestor(node) is @getFurthestAncestor(range.startContainer) and pos1 is "after" and pos2 is "before"

  # returns true if first child and last child is inside range, but node is outside the range
  @isEffectivelyContained : (node, range) ->
    return false  if range.collapsed

    # "node is contained in range."
    return true  if @isContained(node, range)

    # "node is range's start node, it is a Text node, and its length is
    # different from range's start offset."
    return true  if node is range.startContainer and node.nodeType is Node.TEXT_NODE and @getNodeLength(node) isnt range.startOffset

    # "node is range's end node, it is a Text node, and range's end offset is
    # not 0."
    return true  if node is range.endContainer and node.nodeType is Node.TEXT_NODE and range.endOffset isnt 0

    # "node has at least one child; and all its children are effectively
    # contained in range; and either range's start node is not a descendant of
    # node or is not a Text node or range's start offset is zero; and either
    # range's end node is not a descendant of node or is not a Text node or
    # range's end offset is its end node's length."
    return true  if node.hasChildNodes() and [].every.call(node.childNodes, (child) =>
      @isEffectivelyContained child, range
    ) and (not @isDescendant(range.startContainer, node) or range.startContainer.nodeType isnt Node.TEXT_NODE or range.startOffset is 0) and (not @isDescendant(range.endContainer, node) or range.endContainer.nodeType isnt Node.TEXT_NODE or range.endOffset is @getNodeLength(range.endContainer))
    false


  @tobeAfftectedNodeOnDelete : (containerNode, currFocusedNode, cursorOffset, direction) ->
#    console.log(" containerNode is ")
#    console.log(containerNode)
#    console.log(" currFocusedNode is ")
#    console.log(currFocusedNode)
#    console.log(" cursorOffset is ")
#    console.log(cursorOffset)
#    console.log(" direction is ")
#    console.log(direction)

    fetchNonEmptyElementNode = (elementNode, parent) ->

      if elementNode?
        return elementNode if not WordProcessor.Util.isEmptyNode(elementNode, (txtNode) -> txtNode.length is 0 )

        if direction is WordProcessor.WPCaret.DIRECTION_AFTER
          sib = elementNode.nextSibling
        else if direction is WordProcessor.WPCaret.DIRECTION_BEFORE
          sib = elementNode.previousSibling

        parent = elementNode
      else
        return null if parent is containerNode

        if direction is WordProcessor.WPCaret.DIRECTION_AFTER
          sib = parent.nextSibling
        else if direction is WordProcessor.WPCaret.DIRECTION_BEFORE
          sib = parent.previousSibling

        parent = parent.parentNode

      fetchNonEmptyElementNode(sib, parent)

    fetchNonEmptyNode = (node, parent) ->
      if node?
        if node.nodeType is Node.TEXT_NODE
          return node if node.length > 0

          if direction is WordProcessor.WPCaret.DIRECTION_AFTER
            sib = node.nextSibling
          else if direction is WordProcessor.WPCaret.DIRECTION_BEFORE
            sib = node.previousSibling

          fetchNonEmptyNode(sib, parent)
        else if node.nodeType is Node.ELEMENT_NODE
          fetchNonEmptyElementNode(node, parent)
      else
        return null if  parent is containerNode

        if direction is WordProcessor.WPCaret.DIRECTION_AFTER
          sib = parent.nextSibling
        else if direction is WordProcessor.WPCaret.DIRECTION_BEFORE
          sib = parent.previousSibling

        parent = parent.parentNode

        fetchNonEmptyNode(sib, parent)

    if containerNode is currFocusedNode

      if direction is WordProcessor.WPCaret.DIRECTION_AFTER
        return null if cursorOffset is containerNode.childNodes.length
        return fetchNonEmptyNode(containerNode.childNodes[cursorOffset], containerNode)
      else if direction is WordProcessor.WPCaret.DIRECTION_BEFORE
        return null if cursorOffset is 0
        return fetchNonEmptyNode(containerNode.childNodes[cursorOffset - 1], containerNode)
    else
      parent = currFocusedNode.parentNode
      if currFocusedNode.nodeType is Node.TEXT_NODE
        if direction is WordProcessor.WPCaret.DIRECTION_AFTER
          return fetchNonEmptyNode(currFocusedNode.nextSibling, parent) if cursorOffset is currFocusedNode.length
        else if direction is WordProcessor.WPCaret.DIRECTION_BEFORE
          return fetchNonEmptyNode(currFocusedNode.previousSibling, parent) if cursorOffset is 0
        currFocusedNode
      else if currFocusedNode.nodeType is Node.ELEMENT_NODE
        fetchNonEmptyNode(currFocusedNode, parent)

  @containsNodeInSelection : (selection, node, allowPartialSelection=true) ->

    return selection.containsNode(node, allowPartialSelection) if selection.containsNode?

    selectionRange = selection.getRangeAt(0)

    nodeRange = document.createRange();
    nodeRange.selectNode(node)

    # selection_range_start node_range_start node_range_end selection_range_end
    fullSelection = (selectionRange.compareBoundaryPoints(Range.START_TO_START, nodeRange) <= 0 and selectionRange.compareBoundaryPoints(Range.END_TO_END, nodeRange) >=0)

    return fullSelection if not allowPartialSelection

    # selection_range_start node_range_start selection_range_end
    #  or
    # selection_range_start node_range_end selection_range_end
    # or
    # node_range_start selection_range_start selection_range_end node_range_end
    # or
    # fullSelection

    (selectionRange.compareBoundaryPoints(Range.START_TO_START, nodeRange) <= 0 and selectionRange.compareBoundaryPoints(Range.START_TO_END, nodeRange) >=0) or
    (selectionRange.compareBoundaryPoints(Range.END_TO_START, nodeRange) <=0 and selectionRange.compareBoundaryPoints(Range.END_TO_END, nodeRange) >=0) or
    (selectionRange.compareBoundaryPoints(Range.START_TO_START, nodeRange) >=0 and selectionRange.compareBoundaryPoints(Range.END_TO_END, nodeRange) <=0) or
    fullSelection

  @computedRectangle: (node) ->

    return if not node?

    if node.nodeType is Node.TEXT_NODE
      boundRange = document.createRange()
      boundRange.selectNodeContents(node)
      computedRect = boundRange.getBoundingClientRect()
    else
      computedRect = node.getBoundingClientRect()

    computedRect

  @isElementInViewport = (el) ->
    ## Refer : http://stackoverflow.com/questions/123999/how-to-tell-if-a-dom-element-is-visible-in-the-current-viewport/7557433#7557433
    rect = @computedRectangle(el)
    rect.top >= 0 and rect.left >= 0 and rect.bottom <= (window.innerHeight or document.documentElement.clientHeight) and rect.right <= (window.innerWidth or document.documentElement.clientWidth) #or $(window).width()

  @printRange: (range=null) ->
    range = window.getSelection().getRangeAt(0) if not range?
    console.log(" Printing range #{new Date().getTime()}")
    console.log("Start container is ..with offset #{range.startOffset}")
    console.log(range.startContainer)
    console.log("End container is ..with offset #{range.endOffset}")
    console.log(range.endContainer)


  @printNodes : (node, depthLevel) ->
    if not node?
      console.log "Unable to print node as it is undefined or null"
      return
    fetchAttribute = (attrForNode) ->
      return null  if node.nodeType isnt Node.ELEMENT_NODE

      attr_text = ""
      if attrForNode.hasAttributes and attrForNode.hasAttributes()
        attrs = attrForNode.attributes

        for attr in attrs
          attr_text += attr.name + "->" + attr.value + "; "
      attr_text

    spaceCount = 1
    spaceContainer = " "

    if not depthLevel?
      depthLevel = 1
      console.log "Root node name.." + node.nodeName
      console.log "Root node type.." + node.nodeType
      console.log "Root node value.." + node.nodeValue
      console.log "Root node attribute.." + fetchAttribute(node)

    until spaceCount is depthLevel
      spaceContainer = spaceContainer + "   "
      spaceCount++
    console.log spaceContainer + " Children length .." + node.childNodes.length
    console.log spaceContainer + " ..................."

    i = 0
    for childNode in node.childNodes
      console.log spaceContainer + " Child count.." + i
      console.log spaceContainer + " Child node name.." + childNode.nodeName
      console.log spaceContainer + " Child node type.." + childNode.nodeType
      console.log spaceContainer + " Child attribute value.." + fetchAttribute(childNode)
      console.log spaceContainer + " Child node value.." + childNode.nodeValue
      console.log spaceContainer + " ------------------------- "
      @printNodes childNode, depthLevel + 1  if childNode.hasChildNodes()
      i++