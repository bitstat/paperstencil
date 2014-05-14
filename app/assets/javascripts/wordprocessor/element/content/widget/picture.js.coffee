window.WordProcessor.Element.Content.Widget = {} if not window.WordProcessor.Element.Content.Widget?

class WordProcessor.Element.Content.Widget.PictureMorph extends WordProcessor.Element.Content.WidgetMorph

  @__name__ = "WordProcessor.Element.Content.Widget.PictureMorph"
  WordProcessor.Core.MorphMap[@__name__] = @

  @__class__: "element_content_widget_picturemorph"
  @__attribute__: "data-element-content-widget-picturemorph"

  @pictureFileElementId: "addPictureFileSelect"

  @removeMsg = "Are you sure to remove the picture?"

  constructor: (@inEditMode, @pictureStruct)->
    if not @pictureStruct?
      @pictureStruct = {}
      @pictureStruct["id"] = $().unique()
      @pictureStruct["pict_stream"] = null

    @pictureStruct["width"]=140 if not @pictureStruct["width"]?
    @pictureStruct["height"]=70 if not @pictureStruct["height"]?

    @node$ = $("<span></span>");
    @node$.addClass(WordProcessor.Element.Content.Widget.PictureMorph.__class__)

    paddingFront = $("<span class='inline-padding-front'>&nbsp;&nbsp;</span>")
    paddingFront.attr "data-wp-inline-padding-front", "true"
    @node$.append paddingFront

    @pictureContainer = $("<div class='canvas-container'><span style='display:none'>.</span></div>")
    pictureCanvas = $("<canvas width=#{@pictureStruct['width']} height=#{@pictureStruct['height']} class='canvas'></canvas>")
    @pictureContainer.append pictureCanvas
    @node$.append @pictureContainer

    @pictureContainer.resizable()

    @pictureContainer.click((e) =>
      pictureFile$ = $("##{WordProcessor.Element.Content.Widget.PictureMorph.pictureFileElementId}")
      pictureFile$.data("lastFocusedPictureNode", @node$)
      pictureFile$.click()
      e.preventDefault()
    ).on "resize", (e) =>
      canvasContainerWidth = parseInt(@pictureContainer.css("width"))
      canvasContainerHeight = parseInt(@pictureContainer.css("height"))

      pictureCanvas.attr "width", canvasContainerWidth - 6
      pictureCanvas.attr "height", canvasContainerHeight - 6
      ctx = pictureCanvas.get(0).getContext("2d")
      ctx.font = "11px Arial"
      ctx.fillText "Click to add picture", 5, parseInt(pictureCanvas.attr("height")) / 4
      ctx.fillText "Drag lower right to resize", 5, parseInt(pictureCanvas.attr("height")) * (2.5 / 4)

    paddingBack = $("<span class='inline-padding-back'>&nbsp;&nbsp;</span>")
    paddingBack.attr "data-wp-inline-padding-back", "true"
    @node$.append paddingBack

    ###
    Draw picture on canvas *
    ###
    @drawPicture @pictureStruct["pict_stream"]
    delete @pictureStruct["pict_stream"]

    super(@inEditMode, @node$)

  drawPicture: (imgSrc) ->
    canvas = $(".canvas", @node$)
    return  if not canvas?

    ctx = canvas.get(0).getContext("2d")
    if not imgSrc?
      ctx.font = "11px Arial"
      ctx.fillText "Click to add picture", 5, parseInt(canvas.attr("height")) / 4
      ctx.fillText "Drag lower right to resize", 5, parseInt(canvas.attr("height")) * (2.5 / 4)
      return

    img = new Image()
    img.src = imgSrc
    canvasCopy = document.createElement("canvas")
    copyContext = canvasCopy.getContext("2d")
    img.onload = ->
      ###
      To clear canvas image, just set the width/height as same *
      ###
      canvas.attr "width", canvas.attr("width")
      ratioWidth = 1
      ratioHeight = 1
      maxWidth = parseInt(canvas.attr("width"))
      maxHeight = parseInt(canvas.attr("height"))
      ratioWidth = maxWidth / img.width  if img.width > maxWidth
      ratioHeight = maxHeight / img.height  if img.height > maxHeight
      canvasCopy.width = img.width
      canvasCopy.height = img.height
      copyContext.drawImage img, 0, 0
      canvas.width = img.width * ratioWidth
      canvas.height = img.height * ratioHeight
      ctx.drawImage canvasCopy, 0, 0, canvasCopy.width, canvasCopy.height, 0, 0, canvas.width, canvas.height
      window.URL.revokeObjectURL img.src

  toJSONStruct: (fields=[], pictures=[]) ->
    pictData = {}
    $.extend(pictData, @pictureStruct)

    canvas$ = $(".canvas", @node$)

    pictData['width'] = canvas$.attr("width")
    pictData['height'] = canvas$.attr("height")

    pictData["pict_stream"] = canvas$.get(0).toDataURL()

    design = {}
    design["meta"] =  { morph: WordProcessor.Element.Content.Widget.PictureMorph.__name__, picture_ref: pictData.id }
    design['data'] = []

    pictures.push pictData

    { design_struct: design}

  @newEmptyInstanceFromDesign: (inEditMode, design_struct, parent_morph) ->
    meta = design_struct['meta']

    dummy_picture = $("<span>...Loading Picture...</span>")
    dummy_picture.attr("id", meta['picture_ref'])

    new WordProcessor.Core.UnknownElementMorph(inEditMode, dummy_picture)

  @prepare: () ->
    if WordProcessor.Element.Struct.DocMorph.root.inEditMode
      $("##{WordProcessor.Element.Content.Widget.PictureMorph.pictureFileElementId}").change (e) ->
        fileList = @files

        pictNode$ = $(this).data("lastFocusedPictureNode")
        pictMorph = WordProcessor.Core.ElementMorph.getMorph(pictNode$)
        pictMorph.drawPicture window.URL.createObjectURL(fileList[0])
        try
          pictMorph.pictureContainer.resizable("destroy")
        catch error

  @associatePictures = (inEditMode, url) ->
    pictPromise = $.get(url)
    pictPromise.done (data) ->
      if data["status"] is "ok"
        $.each data["pictures"], ->
          pict_structure = this
          eixsting_node$ = $("##{pict_structure["id"]}")
          pict = new WordProcessor.Element.Content.Widget.PictureMorph(inEditMode, pict_structure)
          pict.pictureContainer.resizable "destroy"
          eixsting_node$.replaceWith pict.node$
    pictPromise

  @insertPictureAtCaret: () ->
    eBox = WordProcessor.Element.Struct.DocMorph.editBox

    contentMorph = eBox.contentMorphOfattachedTextNode()
    focusedTextNode = eBox.attachedTextNode() if contentMorph?
    return if not focusedTextNode?

    offset = eBox.getCaretPosition()

    afterCaretContent = contentMorph.extractContentAfter(focusedTextNode, offset)
    picture = new WordProcessor.Element.Content.Widget.PictureMorph()
    contentMorph.node$.append(picture.node$);
    contentMorph.node$.append(afterCaretContent)

    prevSib = picture.node$.get(0).previousSibling
    if not prevSib? or prevSib.nodeType isnt Node.TEXT_NODE or prevSib.nodeValue.length is 0
      blank_space_morph = WordProcessor.Core.TextMorph.blank_space()
      blank_space_morph.insertBefore(picture.node$)

    nextSib = picture.node$.get(0).nextSibling
    if not nextSib? or nextSib.nodeType isnt Node.TEXT_NODE or nextSib.nodeValue.length is 0
      blank_space_morph = WordProcessor.Core.TextMorph.blank_space()
      blank_space_morph.insertAfter(picture.node$)
      nextSib = blank_space_morph.node$.get(0)

    contentMorph.setCaretFocus(nextSib)



