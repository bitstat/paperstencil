window.WordProcessor.Element.Struct = {} if not window.WordProcessor.Element.Struct?

class WordProcessor.Element.Struct.ListMorph extends WordProcessor.Element.StructMorph
  @__name__ = "WordProcessor.Element.Struct.ListMorph"
  WordProcessor.Core.MorphMap[@__name__] = @

  @__class__: "element_struct_listmorph"
  @__attribute__: "data-element-struct-listmorph"

  @TYPE_OL = "OL"
  @TYPE_UL = "UL"

  constructor: (@inEditMode, @type) ->

    if not @type? or @type is WordProcessor.Element.Struct.ListMorph.TYPE_OL
      @node$ = $("<ol>")
    else if @type is WordProcessor.Element.Struct.ListMorph.TYPE_UL
      @node$ = $("<ul>")

    super(@inEditMode, @node$)
    @node$.addClass(WordProcessor.Element.Struct.ListMorph.__class__)

  newEmptyInstance: ->
    return new @.constructor(@inEditMode, @type)

  addItem: (listItemMorph) ->
    @node$.append(listItemMorph.node$)

  merge: (thatList, afterListItemNode$) ->
    afterListItemNode$ = @node$.first("li") if not afterListItemNode$?
    thatList.node$.contents().insertAfter(afterListItemNode$)
    @

  accept: (visitor, endVisit=false) =>
    if endVisit
      visitor.endVisitList(@)
    else
      visitor.startVisitList(@)


  split: (fromListItemMorphNode$, tillListItemMorphNode$) ->

    firstLI = $("li", @node$).first()
    lastLI = $("li", @node$).last()

    if not fromListItemMorphNode$ or not fromListItemMorphNode$.get(0)?
      fromListItemMorphNode$ = firstLI

    if not tillListItemMorphNode$? or not tillListItemMorphNode$.get(0)?
      tillListItemMorphNode$ = lastLI

    if fromListItemMorphNode$.get(0) is tillListItemMorphNode$.get(0)
      ## already at last last list item
      return

    if fromListItemMorphNode$.get(0) is firstLI.get(0) and tillListItemMorphNode$.get(0) is lastLI.get(0)
      ## trying to create exact copy of list
      return

    newList = @newEmptyInstance()
    range = document.createRange()
    range.setStartBefore(fromListItemMorphNode$.get(0))
    range.setEndAfter(tillListItemMorphNode$.get(0))

    listItemFragment = range.extractContents()
    children = listItemFragment.childNodes

    while children.length > 0
      child = children[0]
      newList.node$.append(child)

    newList

  toJSONStruct:(fields=[], pictures=[]) ->
    struct = super(fields, pictures)
    meta = struct['design_struct']['meta']
    $.extend(meta, {type: @type})

    struct

  @newEmptyInstanceFromDesign: (inEditMode, design_struct, parent_morph) ->
    new @(inEditMode, design_struct['meta']['type'])

  @doAction:(type) ->

    collectVisitor = new WordProcessor.Visitor.ListActionCollectVisitor(type)
    sValue = WordProcessor.Visitor.ElementMorphVisitor.iterateOnSelection(collectVisitor)

    if collectVisitor.newlyConstructed? and collectVisitor.newlyConstructed.length > 0

      startMorph = sValue.startMorph
      endMorph = sValue.endMorph
      range = sValue.range

      if collectVisitor.breakCollection and collectVisitor.lastVisitedContentMorph?
        range.setEndAfter(collectVisitor.lastVisitedContentMorph.node$.get(0))
        endMorph = WordProcessor.Visitor.ElementMorphVisitor.endMorphFromRange(range)

      if endMorph instanceof WordProcessor.Element.ContentMorph
        contentEndMorph = endMorph;
      else if endMorph instanceof WordProcessor.Element.StructMorph
        contentEndMorph = endMorph.firstContentMorph()
        return if not contentEndMorph?

      insertVisitor = new WordProcessor.Visitor.ListActionInsertVisitor(collectVisitor.newlyConstructed, startMorph)
      contentEndMorph.visitSelf(insertVisitor)

      range.deleteContents();

      if startMorph instanceof WordProcessor.Element.Content.ListItemMorph
        listStart = startMorph.node$.get(0).parentNode

      if endMorph instanceof WordProcessor.Element.Content.ListItemMorph
        listEnd = endMorph.node$.get(0).parentNode

      startMorph.node$.remove() if startMorph?
      if listStart?
        $(listStart).remove() if not listStart.hasChildNodes()

      endMorph.node$.remove() if endMorph?
      if listEnd?
        $(listEnd).remove()  if not listEnd.hasChildNodes()

      ## Remove old selection
      selection = window.getSelection()
      selection.removeAllRanges()