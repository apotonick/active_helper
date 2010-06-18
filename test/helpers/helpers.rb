class GreedyHelper < ::ActiveHelper::Base
  provides :eat
  
  def eat; 'eat'; end
end

class ThirstyHelper < ::ActiveHelper::Base
  provides :drink, :booze
  
  def drink; 'drink'; end
  def booze; 'booze'; end
end