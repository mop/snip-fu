require 'ragel-parser'

class Parser
  def initialize(str)
    @string = str
  end

  def parse
    RagelParser.run_machine @string
  end
end
