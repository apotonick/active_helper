class ActionController::Base
  
  class_inheritable_array :active_helpers
  self.active_helpers = []
    
  class << self
    # The passed helpers will be imported in the view and thus be available in
    # your template.
    #
    # Example:
    #   require 'active_helpers/thirsty_helper'
    #   
    #   class BeerController < ActionController::Base
    #     active_helper ThirstyHelper
    #
    # Note that the helper file currently is not loaded automatically.
    def active_helper(*classes)
      active_helpers.push(*classes).uniq!
    end
  end
  
  def initialize_template_class_with_active_helper(response)
    initialize_template_class_without_active_helper(response)
    response.template.use ThirstyHelper
  end
  
  alias_method_chain :initialize_template_class, :active_helper
end

class ActionView::Base
  include ActiveHelper
end