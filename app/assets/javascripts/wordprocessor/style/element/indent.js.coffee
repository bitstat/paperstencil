window.WordProcessor.Style.Element = {} if not window.WordProcessor.Style.Element?

class WordProcessor.Style.Element.IndentMorph extends WordProcessor.Style.ContentElementStyleMorph

  constructor: (@node$) ->
    @node$ = $("<span style='padding-left: 20px'>")  if not @node$?
    super(@node$)