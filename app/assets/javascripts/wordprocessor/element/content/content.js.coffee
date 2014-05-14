window.WordProcessor.Element.Content = {} if not window.WordProcessor.Element.Content?

class WordProcessor.Element.Content.WidgetMorph extends WordProcessor.Element.ContentMorph

  @__name__ = "WordProcessor.Element.Content.WidgetMorph"
  @__class__: "element_content_widgetmorph"
  @__attribute__: "data-element-content-widgetmorph"

  @removeMsg = "Are you sure to remove this?"

  constructor: (@inEditMode, @node$) ->
    @node$.addClass(WordProcessor.Element.Content.WidgetMorph.__class__);
    @node$.attr(WordProcessor.Element.Content.WidgetMorph.__attribute__, true);
    super(@inEditMode, @node$)

  convertClickToCaretFocus: ->
    @node$.click (e) =>
      e.stopPropagation()
      e.preventDefault()

  isCursorFocusable: () ->
    false

  @removeAll: (node$) ->
    node$.find(".#{WordProcessor.Element.Content.WidgetMorph.__class__}").remove()

