window.WordProcessor.Element.Content = {} if not window.WordProcessor.Element.Content?

class WordProcessor.Element.Content.LineMorph extends WordProcessor.Element.ContentMorph

  @__name__ = "WordProcessor.Element.Content.LineMorph"
  @__class__: "element_content_linemorph"
  @__attribute__: "data-element-content-linemorph"

  WordProcessor.Core.MorphMap[@__name__] = @

  constructor: (@inEditMode, @node$) ->
    @node$ = $("<div>") if not @node$? or not @node$.get(0)?
    super(@inEditMode, @node$)

    @node$.addClass(WordProcessor.Element.Content.LineMorph.__class__);
    @node$.attr(WordProcessor.Element.Content.LineMorph.__attribute__, true);

  appendContent: (content$) ->
    @node$.append(content$)

  accept: (visitor, endVisit=false) =>
    if endVisit
      visitor.endVisitLine(@)
    else
      visitor.startVisitLine(@)








