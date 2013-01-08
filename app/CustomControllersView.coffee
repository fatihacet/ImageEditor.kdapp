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
    
    for filter of filterControllers
      field = new SliderField
        filterKey : filter
        fieldLabel: filterControllers[filter]
        
      @wrapper.addSubView field
      filterElements.push field
      
      do (field) ->
        field.on "FILTER_CHANGED", (data) =>
          caman.revert()
          filters = {}
          
          filterElements.forEach (controller, index) =>
            field = controller.field
            value = parseInt field.getValue(), 10
            
            if value and value != 0
              caman[field.options.filterKey](value)
            
          caman.render()
            
    
    @filterReverted = ->
      filterElements.forEach (controller, index) =>
        controller.field.setValue 0
      caman.revert()
    
  pistachio: ->
    """
      {{> @wrapper }}
    """