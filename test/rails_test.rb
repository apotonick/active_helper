require File.dirname(__FILE__) + '/test_helper'

require 'action_controller'
require 'action_view'
require 'active_helper/rails' # usually happens in active_helper.rb

class BeerController < ActionController::Base
  def drink
  end
end

ActionController::Routing::Routes.draw do |map|
  map.connect 'beer/:action', :controller => 'beer'
end


class RailsTest < ActionController::TestCase
  context "The ActionController::Base class" do
    should "respond to active_helper" do
      assert_respond_to ActionController::Base, :active_helper
    end
    
    should "store helper constants from active_helper" do
      @controller = Class.new(BeerController)
      @controller.active_helper ThirstyHelper
      assert_equal [ThirstyHelper], @controller.active_helpers
    end
    
    should "inherit helper constants from active_helper" do
      @base_controller = Class.new(BeerController)
      @base_controller.active_helper GreedyHelper
      @controller = Class.new(@base_controller)
      @controller.active_helper ThirstyHelper
      assert_equal [GreedyHelper, ThirstyHelper], @controller.active_helpers
    end
  end
  
  context "An ActionView::Base instance" do
    should "respond to use" do
      @view = ActionView::Base
      assert_respond_to @view, :use
    end
    
  end
  
  context "The view rendered by the controller" do
    should "respond to used helper methods" do
      @controller = BeerController.new
      @controller.class.active_helper ThirstyHelper
      
      get 'drink'
      
      @view = @controller.response.template
      assert_respond_to @view, :booze # from the ThirstyHelper
    end
  end
end