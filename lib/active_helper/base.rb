module ActiveHelper
  class Base
    include ::ActiveHelper
    
    class_inheritable_array :helper_methods
    self.helper_methods = []
    
    class << self
      # Add public methods to the helper's interface. Only methods listed here will 
      # be used to expand the target.
      def provides(*methods)
        helper_methods.push(*methods)
      end
    end
    
    # Expands only the Helper instance itself, not the class.
    def use(*args)
      uses(*args)
    end
  end
end