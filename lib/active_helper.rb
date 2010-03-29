require 'active_support'
require 'forwardable'


module ActiveHelper
  # Expands the target with the provided methods from +helper_class+ by delegating 'em back to a private helper
  # instance.
  def uses(helper_class)
    extend ::SingleForwardable
    ### FIXME: cleaner, test! test if ivar is already present!
    helper_ivar_name = ('@'+helper_class.to_s.demodulize.underscore).to_sym
    
    instance_variable_set(helper_ivar_name, helper_class.new) 
    helper_class.helper_methods.each do |meth|
    puts "delegating on #{self}"
      def_delegator helper_ivar_name, meth
    end
  end
  
  module ExpandedClassMethods
    def uses(helper_class)
    extend ::Forwardable
    ### FIXME: cleaner, test! test if ivar is already present!
    helper_ivar_name = ('@'+helper_class.to_s.demodulize.underscore).to_sym
    
    instance_variable_set(helper_ivar_name, helper_class.new) 
    helper_class.helper_methods.each do |meth|
    puts "delegating on #{self}"
      def_delegator helper_ivar_name, meth
    end
  end
  end
  
  def self.included(base)
    base.extend ::ActiveHelper::ExpandedClassMethods
  end
end

require 'active_helper/base'