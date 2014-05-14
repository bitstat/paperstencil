class WordProcessor.UIActions

  @save: ->
    $('#doc_design_form').submit()

  @addPicture: ->
    WordProcessor.Element.Struct.DocMorph.editBox.disableSync()
    WordProcessor.Element.Content.Widget.PictureMorph.insertPictureAtCaret()

  @addTable: ->
    WordProcessor.Element.Struct.DocMorph.editBox.disableSync()
    WordProcessor.Element.Struct.TableMorph.insertTable()

  @copy: ->
    WordProcessor.Element.Struct.DocMorph.editBox.disableSync()
    WordProcessor.WPClipbaord.doCopy()

  @cut: ->
    WordProcessor.Element.Struct.DocMorph.editBox.disableSync()
    WordProcessor.WPClipbaord.doCut()

  @paste: ->
    WordProcessor.Element.Struct.DocMorph.editBox.disableSync()
    WordProcessor.WPClipbaord.doPaste()

  @italic: ->
    WordProcessor.Element.Struct.DocMorph.editBox.disableSync()
    WordProcessor.Style.Selection.ItalicMorph.doToggleAction()

  @bold: ->
    WordProcessor.Element.Struct.DocMorph.editBox.disableSync()
    WordProcessor.Style.Selection.BoldMorph.doToggleAction()


  @underline: ->
    WordProcessor.Element.Struct.DocMorph.editBox.disableSync()
    WordProcessor.Style.Selection.UnderLineMorph.doToggleAction()

  @strikethrough: ->
    WordProcessor.Element.Struct.DocMorph.editBox.disableSync()
    WordProcessor.Style.Selection.StrikeThroughMorph.doToggleAction()

  @indent: ->
    WordProcessor.Element.Struct.DocMorph.editBox.disableSync()
    WordProcessor.Style.Element.IndentMorph.doApply()

  @outdent: ->
    WordProcessor.Element.Struct.DocMorph.editBox.disableSync()
    WordProcessor.Style.Element.IndentMorph.doRemove()

  @blockquote: ->
    WordProcessor.Element.Struct.DocMorph.editBox.disableSync()
    WordProcessor.Style.Element.BlockQuoteMorph.doApply()

  @justifyleft: ->
    WordProcessor.Element.Struct.DocMorph.editBox.disableSync()
    WordProcessor.Style.Element.JustifyLeftMorph.doApply()

  @justifycenter: ->
    WordProcessor.Element.Struct.DocMorph.editBox.disableSync()
    WordProcessor.Style.Element.JustifyCenterMorph.doApply()

  @justifyright: ->
    WordProcessor.Element.Struct.DocMorph.editBox.disableSync()
    WordProcessor.Style.Element.JustifyRightMorph.doApply()

  @insertorderedlist: ->
    WordProcessor.Element.Struct.DocMorph.editBox.disableSync()
    WordProcessor.Element.Struct.ListMorph.doAction(WordProcessor.Element.Struct.ListMorph.TYPE_OL)

  @insertunorderedlist: ->
    WordProcessor.Element.Struct.DocMorph.editBox.disableSync()
    WordProcessor.Element.Struct.ListMorph.doAction(WordProcessor.Element.Struct.ListMorph.TYPE_UL)

  @delete: ->
    WordProcessor.Element.Struct.DocMorph.editBox.disableSync()
    visitor = new WordProcessor.Visitor.DeleteVisitor()
    WordProcessor.Visitor.ElementMorphVisitor.iterateOnSelection(visitor)

    for morphMap in visitor.fullySelectedOldMorphs
      childMorph = morphMap.morph
      parentMorph = morphMap.parentMorph

      childMorph.node$.remove() if not parentMorph.node$.get(0)?

      if childMorph instanceof WordProcessor.Element.Content.LineMorph
        totalChildren = parentMorph.node$.get(0).childNodes.length
        nextSibMorph = WordProcessor.Core.ElementMorph.getMorph($(childMorph.node$.get(0).nextSibling))
        prevSibMorph = WordProcessor.Core.ElementMorph.getMorph($(childMorph.node$.get(0).previousSibling))
        continue if totalChildren is 1 or (nextSibMorph? and nextSibMorph instanceof WordProcessor.Element.Struct.TableMorph) or (prevSibMorph? and prevSibMorph instanceof WordProcessor.Element.Struct.TableMorph)
        childMorph.node$.remove()
      else if  childMorph instanceof WordProcessor.Element.Content.ListItemMorph
        childMorph.node$.remove()
        parentMorph.node$.remove() if WordProcessor.Util.isEmptyNode(parentMorph.node$.get(0))
      else
        childMorph.node$.remove()

  @insertField: (type) ->
    WordProcessor.Element.Struct.DocMorph.editBox.disableSync()
    focusedMorph = WordProcessor.Element.Struct.DocMorph.editBox.contentMorphOfattachedTextNode()
    txtNode = WordProcessor.Element.Struct.DocMorph.editBox.attachedTextNode()
    offset = WordProcessor.Element.Struct.DocMorph.editBox.getCaretPosition()
    if focusedMorph? and FB.fieldTypesHash[type]?
      WordProcessor.Element.Content.Widget.FieldMorph.insertFieldAtCaret(focusedMorph, txtNode, offset, FB.fieldTypesHash[type].constructField())











