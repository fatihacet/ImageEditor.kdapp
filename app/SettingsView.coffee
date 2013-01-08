class SettingsView extends JView
  
  constructor: (options = {}) ->
    
    options.cssClass = 'settingsView'
    
    super options
    
    @header = new KDHeaderView
      type     : "medium"
      title    : "Edit your image"
      
    revertButton = new KDCustomHTMLView
      tagName  : 'a'
      cssClass : 'revertButton'
      partial  : 'Revert'
      click    : =>
        @emit "FILTERS_REVERTED"


    @header.addSubView revertButton
    
    @presetButtons = new PresetButtonsView
    
    @customControllers = new CustomControllersView
    
    # move to local
    @on "FILTERS_REVERTED", =>
      @customControllers.filterReverted()
    
    
    @on "SHOW_CUSTOM_FILTERS", =>
      @show()
      @customControllers.show()
      @presetButtons.hide()
      
    
    @on "SHOW_PRESET_FILTERS", =>
      @show()
      @customControllers.hide()
      @presetButtons.show()
      
      
    @on "CANCEL_EDITING", =>
      @hide()
      @customControllers.hide()
      @presetButtons.hide()
      @emit "FILTERS_REVERTED"
    
    @hide()
    
  pistachio: ->
    """
      {{> @header }}
      {{> @presetButtons }}
      {{> @customControllers }}
    """