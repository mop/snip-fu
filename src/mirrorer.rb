require 'command_formatter/command_formatter'

# Handles the mirroring feature
class Mirrorer
  attr_accessor :buffer, :tag, :to_insert
  # Initializes the object with the vi-buffer, the tag, which was edited
  # and the string, which should be inserted into the mirrored tags
  #
  # ==== Parameters
  # buffer<Vim::Buffer>:: 
  #   The vi-buffer, which should be modified
  # tag<String>:: 
  #   The tag, which was edited by the user (e.g. ${1:key})
  # insert_str<String>::
  #   The string, the user has inserted
  def initialize(buffer, tag, insert_str)
    @buffer    = buffer
    @tag       = tag
    @to_insert = insert_str
  end

  # Modifies the buffer by replacing each other tag with the insertion string.
  # Regexp-Transformations and other things are handled as well.
  def mirror_tags!
    reduce_buffer_tags do |snippet|
      regex_tag?(snippet) ? transform_regex(snippet) : to_insert
    end
  end

  private
  def reduce_buffer_tags
    each_buffer_tag do |snippet|
      if mirror_tag?(snippet)
        line_number = buffer.to_line_number(snippet)
        line = buffer[line_number]
        pos  = line.index(snippet.start_tag) # The final insertion position
        repl = yield snippet
        buffer[line_number] = line.sub(snippet, "")
        buffer.insert_string(repl, [line_number, pos])
      end
    end
  end

  # Yields each tag within the buffer including nested tags.
  #
  # ==== Yields
  # String:: The appropriate snippet will be yield
  def each_buffer_tag(&block)
  	tags = buffer.buffer_lines.scan_snippets
    tags += nested_buffer_tags(tags)
    tags.each do |snippet|
    	yield snippet
    end
  end

  # Creates recursively a list of snippet-tags in the given list of strings.
  #
  # ==== Parameters
  # tags<Array[String]>:: A list of strings which are snippet-tags who will be
  # recursively mapped and collected so that all nested tags are returned
  #
  # ==== Returns
  # Array[String]:: A list of tags is returned
  #
  # ==== Example
  #
  # nested_buffer_tags(["${1:some${2}thing ${3:funny${4}}}"])
  # # => [ "${2}", "${3:funny${4}}", "${4}" ]
  def nested_buffer_tags(tags)
    return [] if tags.empty?
    nested = tags.map { |t| t.without_tags.scan_snippets }.flatten
    nested + nested_buffer_tags(nested)
  end

  def regex_tag?(tag)
    tag =~ /^
      #{SnipFu::Config[:regex_start_tag]}\d+         
                      # match the opening sequence. e.g.: ${3
      \/              # a regexp tag is followed by a slash
      .*#{SnipFu::Config[:regex_end_tag]}            
                      # until the end there is the transformation pattern
    $/x 
  end

  def transform_regex(snippet)
    to_transform = snippet.sub(
      /^#{SnipFu::Config[:regex_start_tag]}(\d+)/, 
       "#{SnipFu::Config[:start_tag]}#{to_insert}"
    )
    CommandFormatter.new(to_transform).format
  end

  # Returns true if the given str is a mirror tag for this object
  def mirror_tag?(str)
    str.digit_tag == @tag.digit_tag
  end
end
