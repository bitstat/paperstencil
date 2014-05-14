window.WordProcessor.Element.Content = {} if not window.WordProcessor.Element.Content?

class WordProcessor.Element.Content.ListItemMorph extends WordProcessor.Element.ContentMorph
  @__name__ = "WordProcessor.Element.Content.ListItemMorph"
  @__class__: "element_content_listitemmorph"
  @__attribute__: "data-element-content-listitemmorph"

  WordProcessor.Core.MorphMap[@__name__] = @

  constructor: (@inEditMode) ->
    @node$ = $("<li>")
    super(@inEditMode, @node$)
    @node$.addClass(WordProcessor.Element.Content.ListItemMorph.__class__)

  appendContent: (content$) ->
    @node$.append(content$)

  accept: (visitor, endVisit=false) =>
    if endVisit
      visitor.endVisitListItem(@)
    else
      visitor.startVisitListItem(@)

  mergeWith: (anotherListItem) ->
    WordProcessor.Style.ContentElementStyleMorph.removeStyle(anotherListItem)
    anotherLINode = anotherListItem.node$.get(0)

    r = document.createRange()
    r.setStartBefore anotherLINode.firstChild
    r.setEndAfter anotherLINode.lastChild

    lineContent = r.extractContents()
    @node$.append(lineContent)
    anotherListItem.node$.remove()
    @setCursorFocus(false)

  handleReturn: (e, focusedTextNode, cursorOffset) =>
    parentNode = @node$.get(0).parentNode

    lastListItemOfParent = $("li", $(parentNode)).last().get(0)

    if lastListItemOfParent is @node$.get(0) and WordProcessor.Util.isEmptyNode(@node$.get(0))
      nextSib = parentNode.nextSibling

      if nextSib?
        sibMorph = WordProcessor.Core.ElementMorph.getMorph($(nextSib))
        sibMorph.setCaretFocus()
      else
        line = new WordProcessor.Element.Content.LineMorph(@inEditMode)
        line.node$.insertAfter($(parentNode))
        line.setCaretFocus()

      $(lastListItemOfParent).remove()
    else
      super(e, focusedTextNode, cursorOffset)

    e.preventDefault();