caman = null;

class ImageView extends JView

  constructor: (options = {}) ->
    
    options.cssClass = "imageView"
    
    super options
    
    @dropTarget = new KDView 
      cssClass : "imageViewDropTarget"
      partial  : """
        <p class="dropText">Drop your image here from file tree</p>
      """
      bind     : "dragstart dragend dragover drop dragenter dragleave"
      
      
    @openUrlLink = new KDView
      tag      : "a"
      partial  : "Open URL"
      cssClass : "imageEditorLinks url"
      click    :  => 
        @openImageFromUrlModal()
      
      
    @openSampleImageLink = new KDCustomHTMLView
      tag      : "a"
      partial  : "Try sample image"
      cssClass : "imageEditorLinks sampleImage"
      click    : =>
        @openImage()
        
        
    @image = new KDView
      cssClass: "imageEditorImage"
    @image.hide()
    
    
    @resizeNotification = new KDView
      cssClass: "resizeNotification"
      partial : """
        Your image has been resized due to performance issues while editing process. 
        You can still save the original version as processed after your edit.
      """
    @resizeNotification.hide()
    
    
    @dropTarget.on "drop", (e) =>
      @dropTarget.domElement.removeClass "dragover"
      path = e.originalEvent.dataTransfer.getData("Text")
      
      if path
        @fsImage = FSHelper.createFileFromPath path
        @doKiteRequest "base64 #{FSHelper.escapeFilePath path}", (res) => 
          @openImage "data:image/png;base64,#{res}"
          
          
    @dropTarget.on "dragover", (e) =>
      @dropTarget.domElement.addClass "dragover"
      
    
    @dropTarget.on "dragleave", (e) =>
      @dropTarget.domElement.removeClass "dragover"
      
    
    @on "CANCEL_EDITING", => 
      @cancelEditing()
      
      
    @on "SAVE", =>
      droppedFilePath = @fsImage and @fsImage.path
      @openSaveModal droppedFilePath


    @on "RESIZE", =>
      @openResizeModal()
      
      
    @on "CROP", =>
      @openCropModal()
      
      
  pistachio: ->
    """
      {{> @dropTarget }}
      {{> @openUrlLink }}
      {{> @openSampleImageLink }}
      {{> @resizeNotification }}
      {{> @image }}
    """
    
  doSave: (name, callback) ->
    nickname = KD.whoami().profile.nickname
    
    @doKiteRequest "mkdir -p /Users/#{nickname}/ImageEditorFiles/", (res) =>
      [meta, image64] = caman.toBase64().split ","
      
      filePath = "/Users/#{nickname}/ImageEditorFiles/#{name}.png"
      
      if @fsImage and @fsImage.path
        pathArr = @fsImage.path.split "/"
        if pathArr[pathArr.length - 1].split('.')[0] is name
          filePath = @fsImage.path
      
      @fsImageTemp = FSHelper.createFileFromPath filePath + '.txt'
      
      @fsImageTemp.save image64, (err, res) => 
        unless err
          @doKiteRequest "base64 -d #{FSHelper.escapeFilePath @fsImageTemp.path} > #{FSHelper.escapeFilePath filePath} ; rm #{FSHelper.escapeFilePath @fsImageTemp.path}", ->
            new KDNotificationView
              title: "Your image has been saved to #{filePath}"
            callback and callback()
            
            tree             =  (KD.getSingleton "finderController").treeController
            root             = "/Users/#{nickname}"
            imagesRoot       = root + "/ImageEditorFiles"
            firstLevelPath   = if tree.nodes[imagesRoot] then tree.nodes[imagesRoot] else tree.nodes[root]
            
            tree.refreshFolder firstLevelPath
            
            @fsImage = null
            
            KD.utils.wait 1000, =>
              pathArr = filePath.split "/"
              pathArr.length = pathArr.length - 1
              tree.refreshFolder tree.nodes[pathArr.join "/"]
              KD.utils.wait 1000, =>
                tree.selectNode tree.nodes[filePath]
    
  
  openSaveModal: (droppedFilePath) ->
    saveModal = new KDModalViewWithForms
      title                   : "Save Your Image"
      content                 : ""
      cssClass                : "saveImageModal"
      height                  : "auto"
      width                   : 500
      overlay                 : yes
      tabs                    :
        forms                 :
          saveImage           :
            fields            :
              name            :
                label         : "Name: "
                placeholder   : "Write your image name..."
            buttons           :
              Save            :
                title         : "Save"
                style         : "modal-clean-green"
                type          : "submit"
                loader        :
                  color       : "#ffffff"
                  diameter    : 16
                callback      : =>
                  name = saveModal.modalTabs.forms.saveImage.inputs.name.getValue()
                  @doSave name, ->
                    saveModal.destroy()
              Cancel          :
                title         : "Cancel"
                style         : "modal-cancel"
                callback      : ->
                  saveModal.destroy()
    
    if droppedFilePath
      pathArr = droppedFilePath.split '/'
      saveModal.modalTabs.forms.saveImage.inputs.name.setValue pathArr[pathArr.length - 1].split('.')[0]
    
  
  
  openImageFromUrlModal: -> 
    imageFromUrlModal = new KDModalViewWithForms
      title                   : "Open Image with URL"
      content                 : ""
      cssClass                : "openImageURLModal"
      height                  : "auto"
      width                   : 500
      overlay                 : yes
      tabs                    :
        forms                 :
          imageUrlForm        :
            fields            :
              url             :
                label         : "Image URL:"
                placeholder   : "Valid image URL"
            buttons           :
              "Open Image"    :
                title         : "Open Image"
                style         : "modal-clean-green"
                type          : "submit"
                loader        :
                  color       : "#ffffff"
                  diameter    : 16
                callback      : =>
                  url = imageFromUrlModal.modalTabs.forms.imageUrlForm.inputs.url.getValue()
                  if url
                    @doKiteRequest "curl -klAx #{url}|base64", (res) =>
                      @openImage "data:image/png;base64,#{res}"
                      imageFromUrlModal.destroy()
              Cancel          :
                title         : "Cancel"
                style         : "modal-cancel"
                callback      : ->
                  imageFromUrlModal.destroy()
                  
  
  openResizeModal: -> 
    resizeModal = new KDModalViewWithForms
      title                   : "Resize Your Image"
      content                 : """
                                  <div class="modalNotificationText">
                                    You can resize your image up to 600x400 due to performance issues, 
                                    but you can still resize it before save.
                                  </div>
                                """
      cssClass                : "resizeImageModal"
      height                  : "auto"
      width                   : 500
      overlay                 : yes
      tabs                    :
        forms                 :
          resizeForm          :
            fields            :
              width           :
                label         : "Width:"
                placeholder   : "Width"
              height          :
                label         : "Height:"
                placeholder   : "Height"
            buttons           :
              Resize          :
                title         : "Resize Image"
                style         : "modal-clean-green"
                type          : "submit"
                callback      : =>
                  inputs = resizeModal.modalTabs.forms.resizeForm.inputs
                  @doResize inputs.width.getValue(), inputs.height.getValue()
                  resizeModal.destroy()
              Cancel          :
                title         : "Cancel"
                style         : "modal-cancel"
                callback      : ->
                  resizeModal.destroy()

  
  openCropModal: -> 
    cropModal = new KDModalViewWithForms
      title                   : "Crop Your Image"
      content                 : ""
      cssClass                : "cropImageModal"
      height                  : "auto"
      width                   : 500
      overlay                 : yes
      tabs                    :
        forms                 :
          resizeForm          :
            fields            :
              width           :
                label         : "Width:"
                placeholder   : "Width"
              height          :
                label         : "Height:"
                placeholder   : "Height"
              x               :
                label         : "x:"
                placeholder   : "x"
              y               :
                label         : "y:"
                placeholder   : "y"
            buttons           :
              Crop            :
                title         : "Crop Image"
                style         : "modal-clean-green"
                type          : "submit"
                callback      : =>
                  inputs = cropModal.modalTabs.forms.resizeForm.inputs
                  @doCrop inputs.width.getValue(), inputs.height.getValue(), inputs.x.getValue(), inputs.y.getValue()
                  cropModal.destroy()
              Cancel          :
                title         : "Cancel"
                style         : "modal-cancel"
                callback      : ->
                  cropModal.destroy()
                  
    
  doKiteRequest: (command, callback) ->
    KD.getSingleton('kiteController').run command, (err, res) =>
      unless err
        callback(res) if callback
      else 
        new KDNotificationView
          title    : "An error occured while processing your request, try again please!"
          duration : 3000
    
    
  openImage: (imageData) ->
    @dropTarget.hide()
    @openUrlLink.hide()
    @openSampleImageLink.hide()
    
    timestamp  = +new Date
    imageData  = imageData or sampleImageBase64Encoded
    @image.updatePartial("""<img id="image#{timestamp}" src="#{imageData}"/>""");
    
    caman      = Caman """#image#{timestamp}""", =>
      @repositionCanvas()
      
    img        = document.getElementById """image#{timestamp}"""
    imgWidth   = img.width
    imgHeight  = img.height
    
    
    if @isBigFromAccepted imgWidth, imgHeight
      accepted = @calculateResizeDimensions imgWidth, imgHeight
      caman.resize 
        width  : accepted.width
        height : accepted.height
      imageEditor.isResized = true
      
      caman.render()
      @repositionCanvas()
      @resizeNotification.show()
        
    @image.show()
    @repositionCanvas()
    
    new KDNotificationView
      type     : "mini"
      title    : "Now apply filters using buttons in the left toolbar!"
      duration : 2000
    
    @getDelegate().settingsView.emit "SHOW_PRESET_FILTERS"
  
  
  repositionCanvas: ->
    if caman and caman.canvas
      caman.canvas.style.top = @getHeight() / 2 - caman.canvas.height / 2 + "px"
      
  
  cancelEditing: ->
    @dropTarget.show()
    @openUrlLink.show()
    @openSampleImageLink.show()
    @resizeNotification.hide()
    @image.hide()
    @image.updatePartial("")
    caman = null
    imageEditor.isResized = false
    @fsImage = null
  
  
  isBigFromAccepted: (width, height) ->
    max = imageEditor.maxDimensions
    width > max.width || height > max.height
  
  
  calculateResizeDimensions: (width, height) ->
    maxWidth  = imageEditor.maxDimensions.width
    maxHeight = imageEditor.maxDimensions.height
    
    if width > maxWidth || height > maxHeight
      widthRatio  = maxWidth / width;
      heightRatio = maxHeight / height;
      targetRatio = if widthRatio > heightRatio then heightRatio else widthRatio;
      
      width : parseInt width  * targetRatio, 10;
      height: parseInt height * targetRatio, 10;
      
  
  doResize: (width, height) ->
    if @isBigFromAccepted width, height
      accepted = @calculateResizeDimensions width, height
      {width, height} = accepted
      
    caman.resize { width, height }
      
    caman.render()
    imageEditor.isResized  = true
    @cacheResizedDimensions width, height
    @repositionCanvas()
    
    
  doCrop: (width, height, x, y) ->
    caman.crop width, height, x, y
    caman.render()
    imageEditor.isCropped = true
    @cacheCropData width, height, x, y
    @repositionCanvas()
    
    
  cacheResizedDimensions: (width, height) ->
    imageEditor.resizedDimensions = { width, height }
    
  
  cacheCropData: (width, height, x, y) ->
    imageEditor.cropData = { width, height, x, y }