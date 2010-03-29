require 'rubygems'
require 'active_helper'



class UrlHelper < ActiveHelper::Base
  provides  :url_for
  needs     :controller
  
  def url_for(url)
    protocol = controller.https? ? 'https' : 'http'
    "#{protocol}://#{url}"
  end
end

class TagHelper < ActiveHelper::Base
  provides :tag
  
  def tag(name, attributes="")
    "<#{name} #{attributes}>"
  end
end

class FormHelper < TagHelper
  provides :form_tag
  uses UrlHelper
  
  def form_tag(destination)
    destination = url_for(destination)  # in UrlHelper.
    tag(:form, "action=#{destination}")
  end
end

class WebController
  include ActiveHelper
  
  def controller; self;   end
  def https?;     false;  end
end

controller = WebController.new

controller.use TagHelper
puts controller.tag('b')

controller.use UrlHelper
puts controller.url_for('yo')

controller.use FormHelper
puts controller.form_tag('apotomo.de')