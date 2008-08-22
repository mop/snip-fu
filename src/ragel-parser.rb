require 'ext/tag_parser'

module RagelParser
  def self.run_machine(str)
  	elements = TagParser.parse_tags(
      SnipFu::Config[:start_tag], 
      SnipFu::Config[:end_tag],
      str
    )
    elements.map do |element|
      start, stop = element
      [start - 1, stop ]
    end
  end
end
