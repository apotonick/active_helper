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
      # be used to expand the target.
      def provides(*methods)
        helper_methods.push(*methods)
      end
      
      def needs(*methods)
        parent_readers.push(*methods).uniq!
      end
      
      def uses(*classes)
        class_helpers.push(*classes).uniq!
      end
    end
    
    
    include GenericMethods
    attr_reader :parent
    
    def initialize(parent=nil)
      @parent = parent
      extend SingleForwardable
      add_parent_readers!
      add_class_helpers!
    end
    
    def use(helper_class)
      use_for(helper_class, parent) # in GenericMethods.
    end
    
    protected
      # Delegates methods declared with #needs back to parent.
      def add_parent_readers!
        return if @parent.blank? or self.class.parent_readers.blank?
        def_delegator(:@parent, self.class.parent_readers) if @parent
      end
      
      def add_class_helpers!
        self.class.class_helpers.each { |helper| use helper }
      end
  end
end