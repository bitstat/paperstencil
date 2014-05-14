WordProcessor.Visitor = {} if not window.WordProcessor.Visitor?

class WordProcessor.Visitor.PasteVisitor extends WordProcessor.Visitor.ElementMorphVisitor

  constructor: (@pasteableMorphs=[]) ->
    @first = @pasteableMorphs[0]

#    if @first
#      ## Remove block styles from first block element ##
#      @first.node$.find(".#{WordProcessor.WPBlockStyleMorph.styleClass}").each (index, element) =>
#        $(element).replaceWith($(element).contents())

    @rest = @pasteableMorphs[1..]
    super()

  startVisitLine: (lineMorph) ->
    super(lineMorph)
    if @first instanceof WordProcessor.Element.Struct.ListMorph
      @_insertThemAfter(lineMorph, [@first])
    else if @first instanceof WordProcessor.Element.Struct.TableMorph
      @_handleTablePaste(@first, lineMorph)
    else
      @_mergeContentAtCursor(@first.node$.contents())

    @_insertThemAfter(lineMorph, @rest)

  startVisitListItem: (listItemMorph) ->
    super(listItemMorph)
    parentMorph = listItemMorph.parentMorph()

    if @first instanceof WordProcessor.Element.Struct.ListMorph
      parentMorph.merge(@first, listItemMorph.node$)
    else if @first instanceof WordProcessor.Element.Struct.TableMorph
      newList = parentMorph.split(listItemMorph.node$)
      newList.node$.insertAfter(parentMorph.node$) if newList?
      @_handleTablePaste(@first, parentMorph)
    else
      @_mergeContentAtCursor(@first.node$.contents())

    @_insertThemAfter(parentMorph, @rest)

  _insertThemAfter: (currentMorph, toBeInsertedMorphs=[])->
    for morph in toBeInsertedMorphs
      morph.node$.insertAfter(currentMorph.node$)
      currentMorph = morph
    currentMorph

  _mergeContentAtCursor: (contents) ->

    editBox = WordProcessor.Element.Struct.DocMorph.editBox
    contentMorph = editBox.contentMorphOfattachedTextNode()

    textNode = editBox.attachedTextNode()
    offset = editBox.getCaretPosition()
    contentAfterCaret = contentMorph.extractContentAfter(textNode, offset)

    contentMorph.node$.append(contents)
    contentMorph.node$.append(contentAfterCaret)

  _handleTablePaste: (tableMorph, insertAfterMorph) ->
    lineMorph = new WordProcessor.Element.Content.LineMorph(true)
    WordProcessor.Core.TextMorph.blank_space().appendTo(lineMorph.node$)
    @_insertThemAfter(insertAfterMorph, [tableMorph, lineMorph])







