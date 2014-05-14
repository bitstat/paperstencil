WordProcessor.Text = {};

WordProcessor.Text.doContentWrapAction = function(wrap) {
    WordProcessor.cutOrCopySelection("cut");
    var clipBoardContent = WordProcessor.clipBoard.pop();
    WordProcessor.Text.walkAndWrap(clipBoardContent, wrap);
    WordProcessor.clipBoard.push(clipBoardContent);
    WordProcessor.pasteClipboard();
}

WordProcessor.Text.doContainerWrapAction = function(styleContent) {
    var lineContainer;
    var docContainer;

    var $focusNode = $(window.getSelection().focusNode);
    var containerNode = ((lineContainer = $focusNode.parents(".line")).size() > 0 ? lineContainer.first() : ((docContainer = $focusNode.parents(".doc")).size() > 0 ? docContainer.first() : null));
    if(containerNode) {
        var preStyleContent = containerNode.attr("style");
        preStyleContent = preStyleContent === undefined ? "" : preStyleContent
        containerNode.attr("style", preStyleContent + " " + styleContent);
    }
}

WordProcessor.Text.bold = function() {
    WordProcessor.Text.doContentWrapAction("<span style='font-weight: bold'></span>");
}

WordProcessor.Text.italic = function() {
    WordProcessor.Text.doContentWrapAction("<span style='font-style: italic'></span>");
}

WordProcessor.Text.underline = function() {
    WordProcessor.Text.doContentWrapAction("<span style='text-decoration: underline'></span>");
}

WordProcessor.Text.strikethrough = function() {
    WordProcessor.Text.doContentWrapAction("<span style='text-decoration:line-through'></span>");
}

WordProcessor.Text.insertorderedlist = function() {
    WordProcessor.Text.doContentWrapAction("<span style='text-decoration:none'><ul><li></li></ul></span>");
}

WordProcessor.Text.justifyleft = function() {
    WordProcessor.Text.doContainerWrapAction("text-align: left");
}

WordProcessor.Text.justifycenter = function() {
    WordProcessor.Text.doContainerWrapAction("text-align: center");
}

WordProcessor.Text.justifyright = function() {
    WordProcessor.Text.doContainerWrapAction("text-align: right");
}



WordProcessor.Text.walkAndWrap = function(clipBoardContent, wrap) {
    var children = clipBoardContent.get(0).childNodes;
    for(var i=0;i<children.length;i++) {
        var child = children[i];
        var child$ = $(child);

        if(child.nodeType === Node.ELEMENT_NODE) {
            if(child$.hasClass(WordProcessor.fieldClass) || child$.hasClass(WordProcessor.pictureClass)) {
                continue;
            }
        }

        child$.wrap(wrap);
    }
}