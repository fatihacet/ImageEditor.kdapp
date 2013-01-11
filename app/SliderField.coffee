class SliderField extends JView
  constructor: (options = {}) ->
    
    options.cssClass = "sliderFieldContainer"
    
    super options
    
    @label = new KDView
      partial: 
        """
          <div class="label">#{options.fieldLabel}</div>
        """
      
    @field = new KDInputView
      type          : "number"
      attributes    :
        min         : options.filterMin
        max         : options.filterMax
      validate      :
        event       : "keyup"
        rules       :
          required  : yes
        messages    :
          required  : "Enter a value for #{options.fieldLabel}"
      change: =>
        @emit "FILTER_CHANGED", @field.getValue()
    
    @field.getOptions().filterKey = options.filterKey
    
    @field.setValue(0);
    
  pistachio: ->
    """
      {{> @label }}
      {{> @field }}
    """