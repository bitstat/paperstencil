WordProcessor.Visitor = {} if not window.WordProcessor.Visitor?

class WordProcessor.Visitor.ListActionInsertVisitor extends WordProcessor.Visitor.ElementMorphVisitor

  constructor: (@morphs=[], @startMorph) ->
    @first = @morphs[0]
    @rest = @morphs[1..]
    super()

  startVisitLine: (lineMorph) ->
    super(lineMorph)
    @first.node$.insertAfter(lineMorph.node$)
    @_insertThemAfter(@first, @rest)

  startVisitListItem: (listItemMorph) ->
    super(listItemMorph)

    ###
      <ol><li>|One</li><li>Two</li><li>Three</li><li>Four</li></ol>|
      <ol><li>One</li><li>Tw|o</li><li>Three</li><li>Four</li></ol>|
      <ol><li>One</li><li>Two</li><li>Three|</li><li>Four</li></ol>|
      <ol><li>One</li><li>|Two</li><li>Three|</li><li>Four</li></ol>
      |<ol><li>One</li><li>|Two</li><li>Three</li><li>Four</li></ol>
      |<ol><li>|One</li><li>Two</li><li>Three</li><li>Four</li></ol>
      |<ol><li>One</li><li>Two</li><li>Three</li><li>Four|</li></ol>
    ###

    listMorph = listItemMorph.parentMorph()
    return if not listMorph?

#    startMorphRelationWithListMorph = listMorph.node$.compareDocumentPosition(@startMorph.node$)
#
#    isStartMorphWithinList = false
#    if (startMorphRelationWithListMorph is 0 or (startMorphRelationWithListMorph & (Node.DOCUMENT_POSITION_CONTAINED_BY | Node.DOCUMENT_POSITION_FOLLOWING)))
#      ## start morph is also with list. Ie, selection starts within list and ends within list
#      isStartMorphWithinList = true

    ## create new list from selected list item, till last list item of list
    newlyCreatedListMorph = listMorph.split(listItemMorph.node$)
    if newlyCreatedListMorph?
      @first.node$.insertAfter(listMorph.node$)
      newlyCreatedListMorph.node$.insertAfter(@first.node$)
    else if listItemMorph.node$.get(0) is $("li:first", listMorph.node$).get(0)
      insertBefore = @startMorph

      if insertBefore instanceof WordProcessor.Element.Content.ListItemMorph
        insertBefore = insertBefore.parentMorph()

      @first.node$.insertBefore(insertBefore.node$) if insertBefore?
    else if listItemMorph.node$.get(0) is $("li:last", listMorph.node$).get(0)
      @first.node$.insertAfter(listMorph.node$)


    @_insertThemAfter(@first, @rest)

  _insertThemAfter: (currentMorph, toBeInsertedMorphs=[])->
    for morph in toBeInsertedMorphs
      morph.node$.insertAfter(currentMorph.node$)
      currentMorph = morph
    currentMorph


