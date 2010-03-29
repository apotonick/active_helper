require File.dirname(__FILE__) + '/test_helper'

class ActiveHelperTest < Test::Unit::TestCase
  context "#initialize" do
    setup do
      @parent = Object.new
    end
    
    should "receive a parent per default" do
      @helper = ::ActiveHelper::Base.new @parent
      assert_equal @helper.parent, @parent
    end
    
    should "also accept no parent" do
      @helper = ::ActiveHelper::Base.new
      assert_equal @helper.parent, nil
    end
    
    should_eventually "complain if parent doesn't provide accessors declared in #needs"
  end
  
  context "With #parent_readers and #uses," do
    setup do
      @target = Object.new
      @target.class.instance_eval { include ::ActiveHelper }
      @helper_class = Class.new(::ActiveHelper::Base)
      @helper       = @helper_class.new
    end
    
    context "#parent_reader" do
      should "yield an empty array on a fresh instance" do
        assert_equal [], @helper.parent_readers
      end
      
      should "return the method names defined with #needs" do
        @helper.class.instance_eval { needs :controller, :view }
        assert_equal [:controller, :view], @helper.parent_readers
      end
      
      context "with inheritance" do
        setup do
          @helper.class.instance_eval { needs :bottle, :glass }
          @dining = Class.new(@helper.class).new
        end
        
        should "return the inherited parent_readers names" do
          assert_equal [:bottle, :glass], @dining.parent_readers
        end
        
        should "return also the inherited parent_readers names" do
          @dining.class.instance_eval { needs :fork }
          assert_equal [:bottle, :glass, :fork], @dining.parent_readers
        end
        
        should "return a flattend parent_readers names list" do
          @dining.class.instance_eval { needs :bottle }
          assert_equal [:bottle, :glass], @dining.parent_readers
        end
      end
    end
    
    should "delegate the method to the parent when called" do
      @helper_class.instance_eval { needs :bottle }
      @helper = @helper_class.new(@target)
      @target.uses @helper.class
      @target.instance_eval { def bottle; "cheers!"; end }
      assert_equal "cheers!", @helper.bottle
    end
  end
  
  context "#helper_methods and #provides" do
    setup do
      @helper = Class.new(::ActiveHelper::Base).new
    end
    
    should "initialy yield an empty array" do
      assert_equal [], @helper.class.helper_methods
    end
    
    should "grow with calls to #provide" do
      assert_equal [:sleep, :drink], @helper.class.provides(:sleep, :drink)
      assert_equal [:sleep, :drink], @helper.class.helper_methods
    end
    
    should "inherit provided methods from its ancestor classes" do
      @helper.class.provides(:sleep, :drink)
      @kid = Class.new(@helper.class).new
      @kid.class.provides(:eat)
      
      assert_equal [:sleep, :drink, :eat], @kid.class.helper_methods
    end
  end
  
  context "#uses on Helper" do
    setup do
      assert_respond_to ::ActiveHelper::Base, :uses
      @helper = Class.new(::ActiveHelper::Base).new
      assert_respond_to @helper.class, :uses
      assert ! @helper.respond_to?(:eat)
      
      class GreedyHelper < ::ActiveHelper::Base; provides :eat; end
    end
    
    context "instances" do
      should "respond to the new delegated Helper methods" do
        @helper.uses GreedyHelper
        assert_respond_to @helper, :eat
      end
      
      should "be aliased to #use" do
        @helper.use GreedyHelper
        assert_respond_to @helper, :eat
      end
    end
    
    context "classes" do
      should "respond to the new delegated Helper methods" do
        @helper.class.uses GreedyHelper
        assert_respond_to @helper, :eat
      end
      
      should "inherit helper methods to ancestors" do
        class DiningHelper < ::ActiveHelper::Base
          provides :drink
          uses GreedyHelper
          
          def drink;end
        end
        
        @helper = Class.new(DiningHelper).new
        assert_respond_to @helper, :eat   # from uses GreedyHelper.
        assert_respond_to @helper, :drink # from DiningHelper inheritance.
      end
    end
  end
  
  context "#uses on non-helper" do
    setup do
      @target_class = Class.new(Object) # don't pollute Object directly.
      @target_class.instance_eval { include ::ActiveHelper }
      assert_respond_to @target_class, :uses
      
      @target = @target_class.new
      assert ! @target.respond_to?(:eat)
      
      class GreedyHelper < ::ActiveHelper::Base; provides :eat; end
    end
    
    context "instances" do
      should "respond to the new delegated helper methods" do
        @target.uses GreedyHelper
        assert_respond_to @target, :eat
      end
    end
    
    context "classes" do
      should "respond to the new delegated helper methods" do
        @target.class.uses GreedyHelper
        assert_respond_to @target, :eat
      end
      
      should "inherit helper methods to non-helper class" do
        class DiningHelper < ::ActiveHelper::Base
          provides :drink
          uses GreedyHelper
          
          def drink;end
        end
        
        @helper = Class.new(DiningHelper).new
        assert_respond_to @helper, :eat   # from uses GreedyHelper.
        assert_respond_to @helper, :drink # from DiningHelper inheritance.
      end
    end
  end
end