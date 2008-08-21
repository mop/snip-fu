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
    buffer.buffer_lines.scan_snippets.each do |snippet|
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

  def regex_tag?(tag)
    tag =~ /^
      \$\{\d+         # match the opening sequence. e.g.: ${3
      \/              # a regexp tag is followed by a slash
      .*\}            # until the end there is the transformation pattern
    $/x 
  end

  def transform_regex(snippet)
    to_transform = snippet.sub(/^\$\{(\d+)/, "${#{to_insert}")
    CommandFormatter.new(to_transform).format
  end

  # Returns true if the given str is a mirror tag for this object
  def mirror_tag?(str)
    str.digit_tag == @tag.digit_tag
  end
end
