window.WordProcessor.Element.Content.Widget = {} if not window.WordProcessor.Element.Content.Widget?

class WordProcessor.Element.Content.Widget.FieldMorph extends WordProcessor.Element.Content.WidgetMorph

  @__name__ = "WordProcessor.Element.Content.Widget.FieldMorph"
  WordProcessor.Core.MorphMap[@__name__] = @

  @__class__: "element_content_widget_fieldmorph"
  @__attribute__: "data-element-content-widget-fieldmorph"

  @fieldChooseModalIdInDesign : "choose_widget_field_modal"

  @removeMsg = "Are you sure to remove the field?"

  constructor: (@inEditMode, @fbField) ->
    if not @fbField
      @fbField = FB.defaultFieldType().constructField();

    fData = @fbField.data();

    @node$ = $("<span>")
    @node$.addClass(WordProcessor.Element.Content.Widget.FieldMorph.__class__)

    paddingFront = $("<span class='inline-padding-front'>&nbsp;&nbsp;</span>")
    paddingFront.attr "data-wp-inline-padding-front", "true"
    @node$.append paddingFront

    innerSpan = $("<span>")
    innerSpan.addClass("a_field")
    innerSpan.addClass("field_#{fData.type}")
    innerSpan.append(@fbField.design_ui_txt())
    innerSpan.append("&nbsp;");

    @node$.append innerSpan

    paddingBack = $("<span class='inline-padding-back'>&nbsp;&nbsp;</span>")
    paddingBack.attr "data-wp-inline-padding-back", "true"
    @node$.append paddingBack

    if @inEditMode

      modalNode$ = $("##{WordProcessor.Element.Content.Widget.FieldMorph.fieldChooseModalIdInDesign}")
      @node$.click (e) =>
        FB.showFieldForMorph @
        modalNode$.modal "show"

    super(@inEditMode, @node$)

    @setDisplayText() if not @inEditMode

  setDisplayText: (modalFormNode$) ->
    modalFormNode$ = $("#field_container#{@fbField.data().id}") if not modalFormNode$? or not modalFormNode$.get(0)?

    @node$.addClass("error_box") if modalFormNode$.hasClass("error")

    field = @fbField
    fieldType = field.data().type

    if fieldType is "signature"
      sigVal = modalFormNode$.find("input:hidden").val().trim()
      @node$.find(".a_field").each ->
        mElement = $(this)
        if sigVal isnt ""
          sigEle = $("<span>").addClass("sigPad")
          canvas = $("<canvas>").addClass("pad").attr("width", "198").attr("height", "55")
          sigEle.append canvas
          mElement.html sigEle
          mElement.find(".sigPad").signaturePad(displayOnly: true).regenerate sigVal
        else
          mElement.html field.design_ui_txt() + "&nbsp;"
      return

    morph_text = ""
    morph_text = morph_text + modalFormNode$.find("input:checkbox:checked").next().text().trim()
    morph_text = morph_text + modalFormNode$.find("input:radio:checked").next().text().trim()

    val = modalFormNode$.find("textarea").val()

    val = ((if val is `undefined` then "" else val.trim()))

    morph_text = morph_text + val

    modalFormNode$.find("input:file").each ->
      file_path = $(this).val()
      val_arr = file_path.split("\\")
      val = val_arr[val_arr.length - 1]
      val = ((if val is `undefined` then "" else val.trim()))
      morph_text = morph_text + val + " "

    modalFormNode$.find("input:text").each ->
      val = $(this).val()
      val = ((if val is `undefined` then "" else val.trim()))
      morph_text = morph_text + val + " "

    unless morph_text.trim() is "" and (fieldType is "address" or fieldType is "time")
      #Ignore select option
      selected = modalFormNode$.find("select option:selected")
      morph_text = morph_text + modalFormNode$.find("select option:selected").text().trim()  if selected.val() isnt ""
    morph_text = morph_text.trim()
    if morph_text.length is 0
      morph_text = field.design_ui_txt()
    else if morph_text.length > 50
      morph_text = morph_text.substring(0, 46)
      morph_text = morph_text + "..."

    @node$.find(".a_field").each ->
      mElement = $(this)
      mElement.html morph_text + "&nbsp;"

  toJSONStruct: (fields=[], pictures=[]) ->
    fieldData = @fbField.data()

    design = {}
    design["meta"] = { morph: WordProcessor.Element.Content.Widget.FieldMorph.__name__, field_ref: fieldData.id }
    design['data'] = []

    fields.push fieldData
    { design_struct: design}

  @prepare: () =>
    if WordProcessor.Element.Struct.DocMorph.root.inEditMode

      modalNode$ = $("##{WordProcessor.Element.Content.Widget.FieldMorph.fieldChooseModalIdInDesign}")

      $("button[name=btn_done]", modalNode$).click (e) =>

        lastConfiguredField = FB.lastConfiguredField
        currMorphRef = FB.currMorphRef

        currMorphRef.node$.find(".a_field").each ->
          innerNode$ = $(this)
          fData = lastConfiguredField.data()
          lastClass = innerNode$.attr("class").split(" ").pop()
          innerNode$.removeClass lastClass
          innerNode$.addClass "field_#{fData.type}"
          innerNode$.html "#{lastConfiguredField.design_ui_txt()} &nbsp;"

        currMorphRef.fbField = lastConfiguredField
        modalNode$.modal "hide"
        false
    else
      WordProcessor.Element.Struct.DocMorph.root.node$.on "click", ".#{WordProcessor.Element.Content.Widget.FieldMorph.__class__}", ->
        fieldNode$ = $(this)
        morph = WordProcessor.Core.ElementMorph.getMorph(fieldNode$)
        modalFormNode$ = $("#field_container#{morph.fbField.data().id}")
        modalFormNode$.modal "show"

        modalFormNode$.find("button[name=btn_done]").click (e) ->
          morph.setDisplayText(modalFormNode$)

  @deleteField: (node$) ->
    nodeRange = document.createRange()
    nodeRange.setStartBefore node$
    nodeRange.setEndAfter node$
    nodeRange.deleteContents()

  @newEmptyInstanceFromDesign: (inEditMode, design_struct, parent_morph) ->
    meta = design_struct['meta']

    dummy_field = $("<span>...Loading Field...</span>")
    dummy_field.attr("id", meta['field_ref'])

    new WordProcessor.Core.UnknownElementMorph(inEditMode, dummy_field)

  @associateFields = (inEditMode, url) ->
    fieldPromise = $.get(url)
    fieldPromise.done (data) ->
      if data["status"] is "ok"
        $.each data["fields"], ->
          field_struct = this
          existing_node$ = $("#" + field_struct["id"])

          newField = new WordProcessor.Element.Content.Widget.FieldMorph(inEditMode, FB.findFieldType(field_struct["type"]).constructField(field_struct))
          existing_node$.replaceWith newField.node$

    fieldPromise

  @insertFieldAtCaret: (contentMorph, focusedTextNode, offset, fbField=null) ->
    afterCaretContent = contentMorph.extractContentAfter(focusedTextNode, offset)
    field = new WordProcessor.Element.Content.Widget.FieldMorph(true, fbField)
    contentMorph.node$.append(field.node$);
    contentMorph.node$.append(afterCaretContent)

    prevSib = field.node$.get(0).previousSibling
    if not prevSib? or prevSib.nodeType isnt Node.TEXT_NODE or prevSib.nodeValue.length is 0
      blank_space_morph = WordProcessor.Core.TextMorph.blank_space()
      blank_space_morph.insertBefore(field.node$)

    nextSib = field.node$.get(0).nextSibling
    if not nextSib? or nextSib.nodeType isnt Node.TEXT_NODE or nextSib.nodeValue.length is 0
      blank_space_morph = WordProcessor.Core.TextMorph.blank_space()
      blank_space_morph.insertAfter(field.node$)
      nextSib = blank_space_morph.node$.get(0)

    contentMorph.setCaretFocus(nextSib)



