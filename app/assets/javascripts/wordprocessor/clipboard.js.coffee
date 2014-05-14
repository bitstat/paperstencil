class WordProcessor.WPClipbaord

  @content: {}

  @get: (key="morphs") ->
    val = @content[key]
    delete @content[key];
    return val

  @put : (data, key="morphs") ->
    @content[key] = data

  @doCut: ->
    selection = window.getSelection()
    range =  selection.getRangeAt(0)

    visitor = new WordProcessor.Visitor.CutCopyVisitor(true) # doCut set to true
    @_visitForCutOrCopy(visitor)

    selection.removeAllRanges()
    selection.addRange(range)
    WordProcessor.UIActions.delete()

  @doCopy: ->
    visitor = new WordProcessor.Visitor.CutCopyVisitor(false) # doCut set to false
    @_visitForCutOrCopy(visitor)

  @doPaste: ->
    pasteArray = WordProcessor.WPClipbaord.get()
    return if (not pasteArray) or pasteArray.length is 0

    visitor = new WordProcessor.Visitor.PasteVisitor(pasteArray)
    contentMorph = WordProcessor.Element.Struct.DocMorph.editBox.contentMorphOfattachedTextNode()
    contentMorph.accept(visitor) if contentMorph?

  @_visitForCutOrCopy: (visitor) ->
    WordProcessor.Visitor.ElementMorphVisitor.iterateOnSelection(visitor)
    WordProcessor.WPClipbaord.put(visitor.newlyConstructed)

    if visitor.newlyConstructed.length is 1 and visitor.newlyConstructed[0] instanceof WordProcessor.Element.Struct.TableMorph
      tableMorph = visitor.newlyConstructed[0]
      firstRowMorph = tableMorph.rowMorph(0)
      if firstRowMorph['copiedCellsToClipboard'] and firstRowMorph['copiedCellsToClipboard'].length  is 1
        WordProcessor.WPClipbaord.put(firstRowMorph['copiedCellsToClipboard'][0].contentAsMorphs())
