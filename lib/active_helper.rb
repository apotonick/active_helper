require 'active_support'
require 'forwardable'


module ActiveHelper
  module GenericMethods
    def use_for(helper_class, target)
      extend ::SingleForwardable
      
      helper_ivar_name  = ivar_name_for(helper_class)
      helper_instance   = helper_class.new(target)
      
      instance_variable_set(helper_ivar_name, helper_instance) 
      helper_class.helper_methods.each do |meth|
        def_delegator helper_ivar_name, meth
      end
    end
    
    protected
      # Unique ivar name for the helper class in the expanding target.
      def ivar_name_for(object)
        ('@__active_helper_'+("#{object.to_s}".underscore.gsub(/[\/<>@#:]/, ""))).to_sym
      end
  end
  
  
  include GenericMethods
  # Expands the target *instance* with the provided methods from +helper_class+ by delegating 'em back to a private helper
  # Expands only the helped instance itself, not the class.
  def use (helper_class)
    use_for(helper_class, self)
  end
end

require 'active_helper/base'