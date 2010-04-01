module ActiveHelper
  class Base
    class_inheritable_array :helper_methods
    self.helper_methods = []
    
    class_inheritable_array :parent_readers
    self.parent_readers = []
    
    class_inheritable_array :class_helpers
    self.class_helpers = []
    
    class << self
      # Add public methods to the helper's interface. Only methods listed here will 
      # be imported into the target.
      #
      # Example:
      #   class UrlHelper < ActiveHelper::Base
      #     provides :url_for, :link_to
      def provides(*methods)
        helper_methods.push(*methods)
      end
      
      # Define a dependency to another ActiveHelper. All provided methods by the needed
      # helper will be imported into the helper that called needs.
      #
      # Example:
      #   class UrlHelper < ActiveHelper::Base
      #     needs TagHelper
      #
      # will import #tag into UrlHelper.
      def needs(*methods)
        parent_readers.push(*methods).uniq!
      end
      
      # Define a dependency to methods in target. Calls to that methods will be delegated
      # simply back to target.
      #
      # Note: This can also be used to call a helper method from a non-ActiveHelper, which
      # was preliminary included in target.
      #
      # Example:
      #   class UrlHelper < ActiveHelper::Base
      #     uses controller
      #
      # will deletegate calls to #controller to target (i.e. the view instance that #use's 
      # UrlHelper).
      def uses(*classes)
        class_helpers.push(*classes).uniq!
      end
    end
    
    
    include GenericMethods
    attr_reader :parent
    
    def initialize(parent=nil)
      @parent = parent
      setup_delegator_strategy! # in GenericMethods.
      delegate_parent_readers!
      use_class_helpers!
    end
    
    def use(*classes)
      use_for(classes, parent) # in GenericMethods.
    end
    
    protected
      # Delegates methods declared with #needs back to parent.
      def delegate_parent_readers!
        return if @parent.blank? or self.class.parent_readers.blank?
        delegate_methods_to(self.class.parent_readers, :@parent)  # in GenericMethods.
      end
      
      # Imports foreign methods from other use'd helpers.
      def use_class_helpers!
        self.class.class_helpers.each { |helper| use helper }
      end
  end
end