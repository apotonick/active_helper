class GreedyHelper < ::ActiveHelper::Base
  provides :eat
end

class ThirstyHelper < ::ActiveHelper::Base
  provides :drink, :booze
end