module ActiveHelper
  class Base
    include ::ActiveHelper
    
    class_inheritable_array :helper_methods
    self.helper_methods = []
    
    class << self
      # Add public methods to the helper's interface. 
      def provides(*methods)
        helper_methods.push(*methods)
      end
    end
  end
end