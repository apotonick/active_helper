require File.dirname(__FILE__) + '/test_helper'

class ActiveHelperTest < Test::Unit::TestCase
  context "#helper_methods" do
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
  
  context "Helper instances calling #uses" do
    setup do
      @helper = Class.new(::ActiveHelper::Base).new
    end
    
    should "respond to the new delegated Helper methods" do
      assert ! @helper.respond_to?(:eat)
      
      class A < ::ActiveHelper::Base; provides :eat; end
      
      @helper.uses A
      assert_respond_to @helper, :eat
    end
  end
end