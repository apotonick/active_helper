require File.dirname(__FILE__) + '/test_helper'

class ActiveHelperTest < Test::Unit::TestCase
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
    end
  end
  
  context "#uses on non-helpers" do
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
        puts "using uses on #{@target.class}"
        @target.class.uses GreedyHelper
        assert_respond_to @target, :eat
      end
    end
  end
end