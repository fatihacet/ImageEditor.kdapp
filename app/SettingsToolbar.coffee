class SettingsToolbar extends JView
  buttons = [ 
    title    : "Preset Filters"
    cssClass : "preset"
    handler  : "APPLY_PRESET_FILTERS" # presetButtonClicked, preset.view.clicked
  ,
    title    : "Custom Filters"
    cssClass : "custom"
    handler  : "APPLY_CUSTOM_FILTERS"
  ,
    title    : "Resize"
    cssClass : "resize"
    handler  : "RESIZE"
  ,
    title    : "Crop"
    cssClass : "crop"
    handler  : "CROP"
  ,
    title    : "Revert"
    cssClass : "revert"
    handler  : "FILTERS_REVERTED"
  ,
    title    : "Save"
    cssClass : "save"
    handler  : "SAVE"
  ,
    title    : "Cancel"
    cssClass : "cancel"
    handler  : "CANCEL"
  ]

  constructor: (options = {}) ->
    
    options.cssClass = "settingsToolbar" # settings-toolbar
    
    super options
    
    @buttons = {}
    
    @buttonsView = new KDView
      cssClass : "toolbarButtons"
      
    for options in buttons
      do =>
        createdButtonView = new KDButtonView
          # title    : options.title
          cssClass : options.cssClass
          handler  : options.handler
          tooltip  : 
            title : options.title
            placement : "right"
            offset    : 0
            delayIn   : 300
            html      : yes
            animate   : yes
          callback : =>
            @emit "TOOLBAR_ACTION", createdButtonView
          
        @buttons[options.title] = createdButtonView
        @buttonsView.addSubView createdButtonView
    
    
    @on "TOOLBAR_ACTION", (button) => 
      if caman
        delegator = @getDelegate()
        
        switch button.getOptions().handler
          when "FILTERS_REVERTED"     then delegator.settingsView.emit "FILTERS_REVERTED"
          when "SAVE"                 then delegator.imageView.emit    "SAVE"
          when "RESIZE"               then delegator.imageView.emit    "RESIZE"
          when "CROP"                 then delegator.imageView.emit    "CROP"
          when "APPLY_CUSTOM_FILTERS" then delegator.settingsView.emit "SHOW_CUSTOM_FILTERS"
          when "APPLY_PRESET_FILTERS" then delegator.settingsView.emit "SHOW_PRESET_FILTERS"
          when "CANCEL"
            delegator.imageView.emit "CANCEL_EDITING"
            delegator.settingsView.emit "CANCEL_EDITING"
    
    
  pistachio: ->
    """
      {{> @buttonsView }}
    """