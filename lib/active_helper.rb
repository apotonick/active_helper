require 'active_support'
require 'forwardable'
require 'active_helper/base'

module ActiveHelper
  def uses(helper_class)
    extend ::SingleForwardable
    ### FIXME: cleaner, test! test if ivar is already present!
    helper_ivar_name = ('@'+helper_class.to_s.demodulize.underscore).to_sym
    
    instance_variable_set(helper_ivar_name, helper_class.new) 
    helper_class.helper_methods.each do |meth|
      def_delegator helper_ivar_name, meth
    end
  end
end