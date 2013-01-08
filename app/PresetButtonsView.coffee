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
        button = new KDButtonView
          cssClass : "#{filter} clean-gray"
          filter   : filter
          title    : presetFilters[filter]
          callback : =>
            caman.revert() unless imageEditor.isResized
            caman[button.getOptions().filter]()
            caman.render()
            @parent.emit "FILTERS_REVERTED"
          
        @wrapper.addSubView button
          
    
  pistachio: -> 
    """
      {{> @wrapper }}
    """