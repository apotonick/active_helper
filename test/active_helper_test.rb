require File.dirname(__FILE__) + '/test_helper'

class ActiveHelperTest < Test::Unit::TestCase
  def helper_mock(*args)
    Class.new(::ActiveHelper::Base).new(*args)
  end
  
  def helper_in(helper_class, target)
    target.instance_variable_get(target.send(:ivar_name_for, helper_class))
  end
  
  context "#initialize" do
    setup do
      @target = Object.new
      @target.class.instance_eval { include ::ActiveHelper }
      @helper_class = Class.new(::ActiveHelper::Base)
      @greedy_class = @helper_class
    end
    
    should "receive a parent per default" do
      @helper = ::ActiveHelper::Base.new @target
      assert_equal @helper.parent, @target
    end
    
    should "also accept no parent" do
      @helper = ::ActiveHelper::Base.new
      assert_equal @helper.parent, nil
    end
    
    
    
    context "declaring with #needs" do
      setup do
        @target.instance_eval { def bottle; "cheers!"; end }
      end
      
      should_eventually "complain if parent doesn't provide accessors"
      
      should "delegate the method to the parent when called" do
        @helper_class.instance_eval { needs :bottle }
        @helper = @helper_class.new(@target)
        @target.use @helper.class
        
        assert_equal "cheers!", @helper.bottle
      end
      
      # DiningHelper.use GreedyHelper
      #
      # GreedyHelper
      #   needs :bottle
      #
      # target
      #   use DiningHelper
      #   def bottle
      should "always delegate to @target in helpers, for now" do
        @greedy_class.instance_eval { needs :bottle }
        
        @dining = helper_mock(@target)
        @dining.use @greedy_class
        
        assert_equal 'cheers!', helper_in(@greedy_class, @dining).bottle
      end
    end
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
        
        should "return a unique'd parent_readers names list" do
          @dining.class.instance_eval { needs :bottle }
          assert_equal [:bottle, :glass], @dining.parent_readers
        end
      end
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
  
  context "On a Helper" do
    setup do
      assert_respond_to ::ActiveHelper::Base, :uses
      @helper = Class.new(::ActiveHelper::Base).new
      assert_respond_to @helper.class, :uses
      assert ! @helper.respond_to?(:eat)
      
      
    end
    
    context "#use" do
      should "delegate the new Helper methods" do
        @helper.use GreedyHelper
        assert_respond_to @helper, :eat
      end
      
      should "set @parent => @target in the used Helper" do
        @target = Object.new
        @helper = Class.new(::ActiveHelper::Base).new(@target)
        @helper.use GreedyHelper
        assert_equal @target, helper_in(GreedyHelper, @helper).parent # parent of used handler is target, not the using handler!
      end
      
      should "accept multiple helper classes" do
        @helper.use GreedyHelper, ThirstyHelper
        assert_respond_to @helper, :eat
        assert_respond_to @helper, :drink
        assert_respond_to @helper, :booze
      end
      
      should "accept empty helpers with no methods" do
        @empty_helper = helper_mock
        @helper.use  @empty_helper.class
        assert helper_in(@empty_helper.class, @helper)
      end
      
    end
    
    context "#uses" do    
      setup do
        @greedy_class = Class.new(::ActiveHelper::Base)
        @greedy_class.instance_eval do
          uses GreedyHelper
        end
      end
      
      context "with #class_helpers" do
        should "yield an empty array on a fresh instance" do
          @greedy_class = Class.new(::ActiveHelper::Base)
          assert_equal [], @greedy_class.class_helpers
        end
        
        should "remember the passed helpers in #class_helpers" do
          assert_equal [GreedyHelper], @greedy_class.class_helpers
        end
        
        should "inherit ancesting class_helpers" do
          @dining_class = Class.new(@greedy_class)
          @dining_class.instance_eval do
            uses Object
          end
          
          assert_equal [GreedyHelper, Object], @dining_class.class_helpers
        end
      end
      
      should "respond to the new delegated Helper methods" do
        @helper.class.uses GreedyHelper
        assert_respond_to @helper.class.new, :eat
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
  
  context "On a non-helper" do
    setup do
      @target_class = Class.new(Object) # don't pollute Object directly.
      @target_class.instance_eval { include ::ActiveHelper }
      assert_respond_to @target_class, :use
      
      @target = @target_class.new
      assert ! @target.respond_to?(:eat)
    end
    
    context "#use" do
      should "delegate new delegated helper methods" do
        @target.use GreedyHelper
        assert_respond_to @target, :eat
      end
      
      should "set @parent => @target in the used Helper" do
        @target.use GreedyHelper
        assert_equal @target, helper_in(GreedyHelper, @target).parent
      end
      
      should "accept multiple helper classes" do
        @target.use GreedyHelper, ThirstyHelper
        assert_respond_to @target, :eat
        assert_respond_to @target, :drink
        assert_respond_to @target, :booze
      end
    end
    
    #context "#uses" do
    #  should "delegate new delegated helper methods" do
    #    @target.class.uses GreedyHelper
    #    assert_respond_to @target, :eat
    #  end
    #  
    #  should "inherit helper methods to non-helper class" do
    #    class DiningHelper < ::ActiveHelper::Base
    #      provides :drink
    #      uses GreedyHelper
    #      
    #      def drink;end
    #    end
    #    
    #    @helper = Class.new(DiningHelper).new
    #    assert_respond_to @helper, :eat   # from uses GreedyHelper.
    #    assert_respond_to @helper, :drink # from DiningHelper inheritance.
    #  end
    #end
  end
  
  context "#ivar_name_for" do
    setup do
      @helper = helper_mock
    end
    
    should "create a symbol for the class name" do
      assert_equal '@__active_helper_object', @helper.send(:ivar_name_for, Object.new).to_s.sub(/0x.+/, "")
    end
    
    should "create a symbol for an anonym class" do
      assert_equal '@__active_helper_class', @helper.send(:ivar_name_for, Class.new).to_s.sub(/0x.+/, "")
    end
    
    should "create a symbol for namespaced class" do
      
      assert_equal '@__active_helper_active_helperbase', @helper.send(:ivar_name_for, ActiveHelper::Base).to_s.sub(/0x.+/, "")
    end
  end 
end