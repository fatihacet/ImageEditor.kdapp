class SliderField extends JView
  
  # TODO: Revize method naming
  
  constructor: (options = {}) ->
    
    options.cssClass = "sliderFieldContainer"
    
    super options
    
    @label = new KDView
      partial: 
        """
          <div class="label">#{options.fieldLabel}</div>
        """
      
    field = new KDInputView
      validate      :
        event       : "keyup"
        rules       :
          required  : yes
        messages    :
          required  : "Enter a value for #{options.fieldLabel}"
      change: =>
        @emit "FILTER_CHANGED", field.getValue()
    
    field.options.filterKey = options.filterKey
    
    field.setValue(0);
    
    # TODO: Should remove that line
    @field = field;
    
  pistachio: ->
    """
      {{> @label }}
      {{> @field }}
    """