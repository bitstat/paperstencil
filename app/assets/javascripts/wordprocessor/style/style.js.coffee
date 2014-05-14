window.WordProcessor.Style = {} if not window.WordProcessor.Style?

class WordProcessor.Style.ContentElementStyleMorph extends WordProcessor.Core.BaseMorph
  @__name__ = "WordProcessor.Style.ContentElementStyleMorph"

  @__class__: "style_contentelementstylemorph"
  @__attribute__: "data-style-contentelementstylemorph"

  constructor: (@node$) ->
    @node$.addClass(WordProcessor.Style.ContentElementStyleMorph.__class__);
    super @node$

  @applyStyle: (blockMorph) ->
    node = blockMorph.node$.get(0)

    range = document.createRange()
    range.setStartBefore(node.firstChild)
    range.setEndAfter(node.lastChild)

    styleMorph = new @()
    range.surroundContents(styleMorph.node$.get(0))

  @removeStyle: (contentMorph) =>
    element = contentMorph.node$.find(".#{@.__class__}").first()
    $(element).replaceWith($(element).contents())  if element?

  @doApply: ->
    actionVisitor = new WordProcessor.Visitor.StyleActionVisitor(@)
    WordProcessor.Visitor.ElementMorphVisitor.iterateOnSelection(actionVisitor)

  @doRemove: ->
    actionVisitor = new WordProcessor.Visitor.StyleActionVisitor(@, false)
    WordProcessor.Visitor.ElementMorphVisitor.iterateOnSelection(actionVisitor)

class WordProcessor.Style.StructElementStyleMorph extends WordProcessor.Core.BaseMorph


class WordProcessor.Style.SelectionStyleMorph extends WordProcessor.Core.BaseMorph

  @__name__ = "WordProcessor.Style.SelectionStyleMorph"

  @__class__: "style_selectionstylemorph"
  @__attribute__: "data-style-selectionstylemorph"

  constructor: (@node$) ->
    @node$.addClass(WordProcessor.Style.SelectionStyleMorph.__class__);
    super @node$

  @checkPresenceOfStyle: (node) ->
    throw "Not implemented. Should be implemeneted by sub-style morph ?"

  @toggleStyle: (morph, removeStyle=true) ->

    rValue = morph.getRangeOfSelection()
    return if not rValue?

    selectionRange = rValue["range"]

    return if not rValue['range']?

    containerMorphNode$ = morph.node$
    containerMorphNode = containerMorphNode$.get(0)

    ###
      selectionRange.surroundContents will not work when selection is like below.
      <b>12|34>67|8
      To overcome above issue, we are doing somthing like below.
    ###
    afterSelectionRange = document.createRange()
    afterSelectionRange.setStart(selectionRange.endContainer, selectionRange.endOffset)
    afterSelectionRange.setEndAfter(containerMorphNode.lastChild)

    beforeSelectionRange = document.createRange()
    beforeSelectionRange.setStartBefore(containerMorphNode.firstChild)
    beforeSelectionRange.setEnd(selectionRange.startContainer, selectionRange.startOffset)

    currentSelectionRange = document.createRange()
    currentSelectionRange.setStartBefore(containerMorphNode.firstChild)
    currentSelectionRange.setEndAfter(containerMorphNode.lastChild)

    beforeSelectionFragment = beforeSelectionRange.extractContents()
    beforeSelectionFragment.normalize()

    if beforeSelectionFragment.lastChild? and (beforeSelectionFragment.lastChild.nodeType is Node.ELEMENT_NODE) and not beforeSelectionFragment.lastChild.hasChildNodes()
      beforeSelectionFragment.removeChild(beforeSelectionFragment.lastChild)

    afterSelectionFragment = afterSelectionRange.extractContents()
    afterSelectionFragment.normalize()

    if afterSelectionFragment.firstChild? and (afterSelectionFragment.firstChild.nodeType is Node.ELEMENT_NODE) and not afterSelectionFragment.firstChild.hasChildNodes()
      afterSelectionFragment.removeChild(afterSelectionFragment.firstChild)

    currentSelectionFragment = currentSelectionRange.extractContents()
    currentSelectionFragment.normalize()

    tmpContainer = $("<span></span>").append(currentSelectionFragment)
    tmpContainer.find(".#{@.__class__}").each (index, element) =>
      $(element).replaceWith($(element).contents())

    containerMorphNode.appendChild(beforeSelectionFragment)

    if removeStyle
      containerMorphNode$.append(tmpContainer.contents())
    else
      styleMorph = new @()
      containerMorphNode.appendChild(styleMorph.node$.append(tmpContainer.contents()).get(0))

    containerMorphNode.appendChild(afterSelectionFragment)

  @doToggleAction: () ->
    actionVisitor = new WordProcessor.Visitor.StyleToggleActionVisitor(@)
    WordProcessor.Visitor.ElementMorphVisitor.iterateOnSelection(actionVisitor)


