class BaseView extends JView
  
  constructor: (options = {}) ->
    
    options.cssClass = 'imageEditor'
    
    super options
    
    @header = new KDHeaderView
      type    : "big"
      title   : "ImageEditor built with CamanJS and KDFramework!"
    
    eventDistributor = @
    
    @toolbar = new SettingsToolbar
      delegate: eventDistributor
    
    @imageView = new ImageView
      delegate: eventDistributor
      
    @settingsView = new SettingsView
      delegate: eventDistributor
    
    @splitView = new KDSplitView
      cssClass  : "mainSplitView"
      type      : "vertical"
      resizable : no
      sizes     : [ null, 320 ]
      views     : [ @imageView, @settingsView ]
      
    # TODO: clear exports
    window.settingsView = @settingsView 
    window.imageView = @imageView
    window.baseView = @
    window.splitView = @splitView
    
    
  pistachio: ->
    """
      {{> @toolbar }}
      {{> @splitView }}
    """