class ActionController::Base
  
  class_inheritable_array :active_helpers
  self.active_helpers = []
    
  class << self
    # The passed helpers will be imported in the view and thus be available in
    # your template.
    #
    # Example:
    #   class BeerController < ActionController::Base
    #     active_helper ThirstyHelper
    #
    # The helper file usually resides in app/active_helpers/, baby.
    def active_helper(*classes)
      active_helpers.push(*classes).uniq!
    end
  end
  
  def initialize_template_class_with_active_helper(response)
    initialize_template_class_without_active_helper(response)
    response.template.import *self.class.active_helpers
  end
  
  def view_context_with_active_helper
    view_context = view_context_without_active_helper
    view_context.import *self.class.active_helpers
    view_context
  end
  
  
  alias_method_chain :initialize_template_class, :active_helper if ActionPack::VERSION::MAJOR == 2
  alias_method_chain :view_context, :active_helper              if ActionPack::VERSION::MAJOR == 3
end

class ActionView::Base
  include ActiveHelper
end

ActiveSupport::Dependencies.load_paths << Rails.root.join(*%w[app active_helpers]) if defined?(Rails)