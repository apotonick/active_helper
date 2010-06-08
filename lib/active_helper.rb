gem 'activesupport', '~>2.3'
require 'active_support'
require 'forwardable'


module ActiveHelper
  module GenericMethods
    def use_for(classes, target)
      classes.each do |helper_class|
        helper_ivar_name  = ivar_name_for(helper_class)
        helper_instance   = helper_class.new(target)
        
        instance_variable_set(helper_ivar_name, helper_instance) 
        delegate_methods_to(helper_class.helper_methods, helper_ivar_name)
      end
    end
    
    protected
      def setup_delegator_strategy!
        extend SingleForwardable
      end
      
      # Implements the actual delegation.
      def delegate_methods_to(methods, ivar)
        return if methods.blank?
        def_delegators ivar, *methods
      end
      
      # Unique ivar name for the helper instance in the expanding target.
      def ivar_name_for(object)
        ('@__active_helper_'+("#{object.to_s}".underscore.gsub(/[\/<>@#:]/, ""))).to_sym
      end
  end
  
  
  include GenericMethods
  # Imports the provided methods from +classes+ into the target *instance* (the receiver).
  # All new methods in the target will be delegated back to the helpers.
  # 
  # Note: Imports only into the helped instance itself, not the class.
  #
  # Example:
  #   class View
  #   end
  #
  #   view = View.new
  #   view.use UrlHelper, DataMapperHelper
  def use (*classes)
    setup_delegator_strategy!
    use_for(classes, self)
  end
end

require 'active_helper/base'