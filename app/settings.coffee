imageEditor =
  
  # allowed maximum dimensions, need this to avoid performance issues on rendering
  maxDimensions     : 
    width           : 600
    height          : 400
    
  # is resized previously
  isResized         : false
  
  # is resized previously
  isCropped         : false
  
  # is there any active editing process
  isProcessing      : false
  
  resizedDimensions :
    width           : null
    height          : null
    
  cropData          :
    width           : null
    height          : null
    x               : null
    y               : null