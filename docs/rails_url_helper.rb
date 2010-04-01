require 'rubygems'
require 'active_helper'
require 'action_view'
require 'action_controller'
require 'action_controller/base'
require 'action_controller/request_forgery_protection'


# An example that shows how to wrap the Rails UrlHelper in a good class.

module Rails
  class UrlHelper < ActiveHelper::Base
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper  # did you know that #escape_once comes from here?
    provides :url_for, :link_to, :button_to # add more if you need.
    
    needs :protect_against_forgery?
    
    def initialize(*args)
      super(*args)
      @controller = parent.controller # setup @controller so the original module can access it.
    end
  end
end


controller = ActionController::Base.new
view       = ActionView::Base.new([], {}, controller)



view.extend ActiveHelper
view.helpers.send :include, controller.class.master_helper_module
view.use Rails::UrlHelper  # this should happen in ActionController::Base#render.

puts view.url_for('bar/drink') # and this would be happ'ning inside a view template.
puts view.link_to "Follow me!", 'bar/drink'
puts view.button_to "Click me!", 'bar/drink'