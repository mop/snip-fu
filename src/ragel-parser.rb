require 'ext/tag_parser'

module RagelParser
  def self.run_machine(str)
  	elements = TagParser.parse_tags(str)
    elements.map do |element|
      start, stop = element
      [start - 1, stop ]
    end
  end
end
