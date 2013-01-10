class CustomControllersView extends JView

  constructor: (options = {}) ->
    
    options.cssClass = "customControllersView"
    
    super options
    
    filterControllers = 
      "brightness"  : "Brightness"
      "contrast"    : "Contrast"
      "gamma"       : "Gamma"
      "saturation"  : "Saturation"
      "sepia"       : "Sepia"
      "exposure"    : "Exposure"
      "noise"       : "Noise"
      "hue"         : "Hue"
      "vibrance"    : "Vibrance"
      "clip"        : "Clip"
      
    @wrapper = new KDView
    
    filterElements = []
    
    timer = null
    
    for filter of filterControllers
      field = new SliderField
        filterKey : filter
        fieldLabel: filterControllers[filter]
        
      @wrapper.addSubView field
      filterElements.push field
      
      
      do (field) ->
        field.on "FILTER_CHANGED", (data) =>
          clearTimeout timer
          timer = setTimeout ->
            caman.reset()
            caman.render()
            if imageEditor.isResized
              caman.resize
                width  : imageEditor.resizedDimensions.width
                height : imageEditor.resizedDimensions.height
              caman.render()
              
            if imageEditor.isCropped
              data = imageEditor.cropData
              caman.crop data.width, data.height, data.x, data.y
              caman.render()
            
            filterElements.forEach (controller, index) =>
              field = controller.field
              value = parseInt field.getValue(), 10
              
              if value and value != 0
                caman[field.options.filterKey](value)
              
            caman.render()
          , 300
    
    @filterReverted = ->
      filterElements.forEach (controller, index) =>
        controller.field.setValue 0
      caman.reset()
      imageEditor.isResized = false
      imageEditor.isCropped = false
    
  pistachio: ->
    """
      {{> @wrapper }}
    """