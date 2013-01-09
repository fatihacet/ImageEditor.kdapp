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
    
    
    @dropTarget.bindEvent 'drop'
    @dropTarget.on 'drop', (e) ->
      console.log e.originalEvent.dataTransfer
      
      
    @on "CANCEL_EDITING", => 
      @cancelEditing()
      
      
    @on "SAVE", =>
      new KDNotificationView
        title: "This feature will be implemented soon. Stay tuned!"
        
      
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
                    KD.getSingleton('kiteController').run "curl -klAx #{url}|base64", (err, res) =>
                      @openImage "data:image/png;base64,#{res}"
                      imageFromUrlModal.destroy()
              Cancel          :
                title         : "Cancel"
                style         : "modal-clean-red"
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
                style         : "modal-clean-red"
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
                style         : "modal-clean-red"
                callback      : ->
                  cropModal.destroy()


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
      title    : "Now apply filters using buttons in the left toolbar!"
      duration : 2000
  
  
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
      width    = accepted.width
      height   = accepted.height
      
    caman.resize
      width  : width
      height : height
      
    caman.render()
    imageEditor.isResized  = true
      
      
  doCrop: (width, height, x, y) ->
    caman.crop width, height, x, y
    caman.render()
    imageEditor.isResized = true