window.WordProcessor = {} if not window.WordProcessor?
WordProcessor.Mixin = {} if not window.WordProcessor.Mixin?

class WordProcessor.Mixin.SerializationRelated

  toJSONStruct: (fields=[], pictures=[]) ->
    design = {meta:{}, data:[]}
    fields = [] if not fields?
    pictures = [] if not pictures?

    $.extend(design['meta'], { morph: @.constructor.__name__})

#    console.log("Creating JSON Struct for #{@.constructor.__name__}")

    for child in @node$.get(0).childNodes
      if child.nodeType is Node.TEXT_NODE
        design['data'].push child.nodeValue
      else if child.nodeType is Node.ELEMENT_NODE
        node$ = $(child)
        childMorph = WordProcessor.Core.ElementMorph.getMorph(node$)

        ## For style elements there wonnt be any attached morph
        if (not childMorph?) or typeof childMorph.toJSONStruct isnt 'function'
          childMorph = new WordProcessor.Core.UnknownElementMorph(true, $(child))

        childStruct = childMorph.toJSONStruct(fields, pictures)

        if childMorph instanceof WordProcessor.Element.ContentMorph
          style = WordProcessor.Style.Element.JustifyMorph.chkStyle(childMorph)
          meta = childStruct['design_struct']['meta']
          meta['style'] = style if style?

        if childMorph instanceof WordProcessor.Core.UnknownElementMorph
          childMorph.addExtraMetaData(childStruct)

        design["data"].push childStruct['design_struct']

    { design_struct: design}

  designToContent: (design_struct) ->

#    console.log(design_struct)

    data = design_struct['data']
    meta = design_struct['meta']

    return if not data?

    @node$.addClass(meta['style']) if meta['style']?

    if not data?
      WordProcessor.Core.TextMorph.blank_space().appendTo(@node$)
      return @

    for child_struct in data
      if child_struct.constructor is String
        if child_struct.trim() is ""
          @node$.append("&nbsp;")
        else
          @node$.append(child_struct)
      else if child_struct.constructor is Object
        morphName = child_struct['meta']['morph']
        morphKlass = WordProcessor.Core.MorphMap[morphName] if morphName?

        continue if not morphKlass?

#        console.log(" Converting design to content for #{morphName}")

        morph = morphKlass.newEmptyInstanceFromDesign(@inEditMode, child_struct, @)
#        console.log(" morphKlass #{morphName}")
        morph.designToContent(child_struct)
        @node$.append(morph.node$)

    @
