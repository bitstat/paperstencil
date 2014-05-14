window.DemoGuide = {}

DemoGuide.showOverlay = ->
  $(".demo_overlay").height($(window).height()-10)
  $(".demo_overlay").width($(window).width()-10)
  $(".demo_overlay").fadeTo 1000, 0.4

DemoGuide.hideOverlay = ->
  $(".demo_overlay").fadeTo 1000, 0
  $(".demo_overlay").css "display", "none"

DemoGuide.endDemo =->
  guiders.hideAll true
  DemoGuide.hideOverlay()

DemoGuide.setDesignEditCaptureTabActive = ->
  tabs = $(".doc_actions .nav-tabs")
  $("a[href=\"#ribbon_capture\"]", tabs).tab "show"

DemoGuide.showDocActionsInDesignList = ->
  $(".doc_actions", DemoGuide.design_list_demo_doc).show();


DemoGuide.showHowtoAddFIeldsInDesignEdit = ->
  guiders.hideAll true
  guiders.show "doc_design_capture_tab"



DemoGuide.navigatetoDesignEdit = ->
  edit_href = $(".doc_actions .design_edit a", DemoGuide.design_list_demo_doc).attr('href')
  document.location.href = edit_href

DemoGuide.startDemo = ->
  DemoGuide.showOverlay()
  guiders.hideAll true
  guiders.show "doc_list_title"

DemoGuide.showDesignListGuide = ->
  DemoGuide.showOverlay()
  guiders.hideAll true
  guiders.show "doc_list_welcome"


DemoGuide.showDesignEditGuide = ->
  DemoGuide.showOverlay()
  guiders.hideAll true
  guiders.show "doc_design_welcome"



DemoGuide.initDesignListGuides = ->

  DemoGuide.design_list_demo_doc = $("ul.doc_list li:first");

  guiders.createGuider(
    id: "doc_list_welcome"
    title: "Demo of Paperstencil"
    description: "Welcome to demo of Paperstencil. <br/><br/> User actions are disabled during this demo. <br/><br/> At the end of this 1 minute demo, user actions will be <b>enebled.</b>"
    position: 6
    width: 300
    xButton: true
    onClose: DemoGuide.endDemo
    buttons: [{name : "Close"}, {name: "Start demo >> ", onclick: DemoGuide.startDemo}]

  )

  guiders.createGuider(
    id: "doc_list_title"
    title: "Sample document"
    description: "This is a sample document that we have created for you. <br/><br/> New document can be created by clicking on <b>'Create new'</b> button at top right"
    position: 3
    width: 300
    attachTo: ".doc_list li:first .doc_title"
    buttons: [{name: "next"}],
    onShow: DemoGuide.showDocActionsInDesignList
    xButton: true
    onClose: DemoGuide.endDemo
    next: "doc_list_compose"
  )

  guiders.createGuider(
    id: "doc_list_compose"
    title: "Compose"
    description: "Start/resume composing the documents that you have added."
    position: 6
    width: 300
    xButton: true
    onClose: DemoGuide.endDemo
    attachTo: ".doc_list li:first .doc_actions li.design_edit"
    buttons: [{name: "Take me to compose page", onclick: DemoGuide.navigatetoDesignEdit}]
  )

DemoGuide.initDesignEditGuides = ->

  guiders.createGuider(
    id: "doc_design_welcome"
    title: "Composing a document"
    description: "What makes Paperstencil set apart from others is, its ability to add user input field <i>such as Address, Signature and others, <u>in-line within paragraphs, lines, tables.</u></i>"
    position: 6
    width: 300
    xButton: true
    onClose: DemoGuide.endDemo
    buttons: [{name: "next"}],
    next: "doc_design_field_date"
  )

  guiders.createGuider(
    id: "doc_design_field_date"
    title: "Date field"
    description: "Date that we want to capture from end user, appears alone side other text content. <br/><br/> Date field naturally flow along in-line with surrounding contents."
    attachTo: ".field_date"
    position: 6
    width: 300
    xButton: true
    onClose: DemoGuide.endDemo
    buttons: [{name: "Show how it was added", onclick: DemoGuide.showHowtoAddFIeldsInDesignEdit}],
  )


  guiders.createGuider(
    id: "doc_design_capture_tab"
    title: "Data capture"
    description: "User input fileds shall be added in-line along text content by <br/><br/><b>1.&nbsp;</b>clicking on data capture icons or <br/><br/><b>2.&nbsp;</b>by typing <b>...</b> <i>(three dots)</i> consecutively."
    attachTo: ".capture_tab"
    position: 6
    width: 300,
    onShow: DemoGuide.setDesignEditCaptureTabActive,
    xButton: true
    onClose: DemoGuide.endDemo
    buttons: [{name: "next"}],
    next : "doc_design_render_document",
  )

  guiders.createGuider(
    id: "doc_design_field_config"
    title: "Capture field config"
    description: "Added fields can be easily configured and changed to other field by clicking on them. We can also <i>set validation</i> on them during configuration."
    width: 300,
    xButton: true
    onClose: DemoGuide.endDemo
    buttons: [{name: "next"}],
    next : "doc_design_render_document",
  )

  guiders.createGuider(
    id: "doc_design_render_document"
    title: "Render - that user sees"
    description: "By clicking on it will render composed document as seen by end users."
    attachTo: ".render_document"
    position: 5
    width: 300,
    xButton: true
    onClose: DemoGuide.endDemo
    buttons: [{name: "next"}],
    next : "doc_design_share_document",
  )

  guiders.createGuider(
    id: "doc_design_share_document"
    title: "Share it"
    description: "Once document is composed, it can be shared with others. By clicking on it will give <i>options to control who can acees this document</i>."
    attachTo: ".share_document"
    position: 5
    width: 300,
    xButton: true
    onClose: DemoGuide.endDemo
    buttons: [{name: "Done", onclick: DemoGuide.endDemo}],
  )


