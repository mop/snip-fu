require 'ragel-parser'

class Parser
  def initialize(str)
    @string = str
  end

  def parse
    run_machine @string
    @elements.map do |element|
      start, stop = element
      [start - 1, stop ]
    end
  end
end
