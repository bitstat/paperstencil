window.WordProcessor.Style.Element = {} if not window.WordProcessor.Style.Element?

class WordProcessor.Style.Element.JustifyMorph extends WordProcessor.Style.ContentElementStyleMorph

  @__class__ : "style_justify_morph"

  @match_re = new RegExp("\\bstyle_justify_morph_\\S+", "g");

  constructor: (@node$) ->
    super(@node$)
    @node$.addClass(@.constructor.__class__)

  @applyStyle: (contentMorph) ->
    @removeStyle(contentMorph)
    contentMorph.node$.addClass("#{@.__class__}")

  @chkStyle : (contentMorph) ->
    justifyStyle = contentMorph.node$.attr('class').match(@match_re)
    return justifyStyle[0] if justifyStyle?

  @removeStyle: (contentMorph) =>
    contentMorph.node$.removeClass (index, css) =>
      (css.match(@match_re) or []).join " "


class WordProcessor.Style.Element.JustifyLeftMorph extends WordProcessor.Style.Element.JustifyMorph

  @__class__ : "style_justify_morph_left"


class WordProcessor.Style.Element.JustifyRightMorph extends WordProcessor.Style.Element.JustifyMorph

  @__class__ : "style_justify_morph_right"


class WordProcessor.Style.Element.JustifyCenterMorph extends WordProcessor.Style.Element.JustifyMorph

  @__class__ : "style_justify_morph_center"
