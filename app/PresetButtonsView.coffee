class PresetButtonsView extends JView

  constructor: (options = {}) ->
    
    options.cssClass = "presetButtonsView"
  
    super options
      
    @wrapper = new KDView
    
    presetFilters = 
      "vintage"      : "Vintage"
      "lomo"         : "Lomo"
      "clarity"      : "Clarity"
      "sinCity"      : "Sin City"
      "sunrise"      : "Sunrise"
      "crossProcess" : "Cross Process"
      "orangePeel"   : "Orange Peel"
      "love"         : "Love"
      "grungy"       : "Grungy"
      "jarques"      : "Jarques"
      "pinhole"      : "Pinhole"
      "oldBoot"      : "Old Boot"
      "glowingSun"   : "Glowing Sun"
      "hazyDays"     : "Hazy Days"
      "herMajesty"   : "Her Majesty"
      "nostalgia"    : "Nostalgia"
      "hemingway"    : "Hemingway"
      "concentrate"  : "Concentrate"
    
    for filter of presetFilters
      do => 
        filterName = presetFilters[filter]
        
        button = new KDButtonView
          cssClass : "#{filter} clean-gray"
          filter   : filter
          title    : filterName
          callback : =>
            notification = new KDNotificationView
              type     : "mini"
              title    : "Applying #{filterName} filter..."
              duration : 0
            
            if imageEditor.isResized
              caman.reset()
              caman.render()
              caman.resize
                width  : imageEditor.resizedDimensions.width
                height : imageEditor.resizedDimensions.height
              caman.render()
            
            if imageEditor.isCropped
              caman.reset()
              caman.render()
              data = imageEditor.cropData
              caman.crop data.width, data.height, data.x, data.y
              caman.render()
            
            caman[button.getOptions().filter]()
            caman.render ->
              notification.notificationSetTitle "#{filterName} filter applied."
              notification.notificationSetTimer 2000
            @parent.emit "FILTERS_REVERTED" unless imageEditor.isResized
          
        @wrapper.addSubView button
          
    
  pistachio: -> 
    """
      {{> @wrapper }}
    """