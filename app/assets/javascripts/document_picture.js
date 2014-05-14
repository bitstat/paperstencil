WordProcessor.Picture = {
    lastClickedPictureCanvasContainer : [],
    pictureClass: "wp_picture"
};

WordProcessor.Picture.addPicture = function () {
    var newNode = WordProcessor.Picture.newPictureElement();
    WordProcessor.insertInLineNode(newNode);
    WordProcessor.Picture.initPictureClick(newNode);
};

WordProcessor.Picture.initPictureClick = function (inLinePictureNode) {
    $(".canvas-container", inLinePictureNode).resizable().click(function (e) {
        WordProcessor.Picture.lastClickedPictureCanvasContainer.push($(this));
        $("#addPictureFileSelect").click();
        e.preventDefault(); // prevent navigation to "#"
    }).on('resize', function (e) {
            var canvas = $(".canvas", $(this));

            var canvasContainerWidth = parseInt($(this).css("width"));
            var canvasContainerHeight = parseInt($(this).css("height"));

            canvas.attr("width", canvasContainerWidth - 6);
            canvas.attr("height", canvasContainerHeight - 6);

            var ctx = canvas.get(0).getContext('2d');
            ctx.font = "11px Arial";
            ctx.fillText("Click to add picture", 5, parseInt(canvas.attr("height")) / 4);
            ctx.fillText("Drag lower right to resize", 5, parseInt(canvas.attr("height")) * (2.5 / 4));
        });
}

WordProcessor.Picture.initAddPicture = function () {

    $("#addPictureFileSelect").change(function () {

        var fileList = this.files;

        var canvasContainer = WordProcessor.Picture.lastClickedPictureCanvasContainer.pop();
        WordProcessor.Picture.drawPicture(canvasContainer, window.URL.createObjectURL(fileList[0]));
        canvasContainer.resizable('destroy');
    });
}

WordProcessor.Picture.drawPicture = function (canvasContainer, imgSrc) {

    var canvas = $(".canvas", canvasContainer);

    if (canvas === undefined || canvas === null) {
        return;
    }

    var ctx = canvas.get(0).getContext('2d');

    if (imgSrc === null || imgSrc === undefined) {
        ctx.font = "11px Arial";
        ctx.fillText("Click to add picture", 5, parseInt(canvas.attr("height")) / 4);
        ctx.fillText("Drag lower right to resize", 5, parseInt(canvas.attr("height")) * (2.5 / 4));
        return;
    }

    var img = new Image();
    img.src = imgSrc;

    var canvasCopy = document.createElement("canvas");
    var copyContext = canvasCopy.getContext("2d");

    img.onload = function () {


        /** To clear canvas image, just set the width/height as same **/
        canvas.attr("width", canvas.attr("width"))

        var ratioWidth = 1;
        var ratioHeight = 1;
        var maxWidth = parseInt(canvas.attr("width")), maxHeight = parseInt(canvas.attr("height"));

        if (img.width > maxWidth) {
            ratioWidth = maxWidth / img.width;
        }

        if (img.height > maxHeight) {
            ratioHeight = maxHeight / img.height;
        }

        canvasCopy.width = img.width;
        canvasCopy.height = img.height;
        copyContext.drawImage(img, 0, 0);

        canvas.width = img.width * ratioWidth;
        canvas.height = img.height * ratioHeight;
        ctx.drawImage(canvasCopy, 0, 0, canvasCopy.width, canvasCopy.height, 0, 0, canvas.width, canvas.height);

        window.URL.revokeObjectURL(this.src);
    }
}

WordProcessor.Picture.newPictureElement = function (defaultPicture) {

    if (defaultPicture === undefined || defaultPicture === null) {
        defaultPicture = {};
        defaultPicture["id"] = $().unique();
        defaultPicture["pict_stream"] = null;
    }

    var newNode = $("<span id='" + defaultPicture.id + "' class='" + WordProcessor.Picture.pictureClass + "'></span>");
    newNode.attr("data-wp-inline", "true");

    var paddingFront = $("<span class='inline-padding-front'>&nbsp;&nbsp;</span>");
    paddingFront.attr("data-wp-inline-padding-front", "true");
    newNode.append(paddingFront);

    var pictureContainer = $("<div class='canvas-container'><span style='display:none'>.</span></div>");
    var pictureCanvas = $("<canvas width=140 height=70 class='canvas'></canvas>");

    pictureContainer.append(pictureCanvas);
    newNode.append(pictureContainer);

    var paddingBack = $("<span class='inline-padding-back'>&nbsp;</span>");
    paddingBack.attr("data-wp-inline-padding-back", "true");
    newNode.append(paddingBack);

    /** Draw picture on canvas **/
    WordProcessor.Picture.drawPicture(pictureContainer, defaultPicture["pict_stream"]);

    delete defaultPicture["pict_stream"];
    newNode.data("picture", defaultPicture);

    return newNode;
};

WordProcessor.Picture.associatePictures = function (url) {
    $.get(url).done(function (data) {
        if (data["status"] === "ok") {
            $.each(data["pictures"], function () {
                var pict = this;
                var $node = $("#" + pict["id"]);
                var newFieldNode$ = WordProcessor.Picture.newPictureElement(pict);
                $node.replaceWith(newFieldNode$);
                WordProcessor.Picture.initPictureClick(newFieldNode$);
                $(".canvas-container", newFieldNode$).resizable('destroy');
                WordProcessor.createTxtNodeAfterThis(newFieldNode$.get(0));
            });
        }
    });
}