require 'parser'
module GeditSnippetMatcher
  module GeditSnippetMatcherGroupMethods
  end

  module GeditSnippetMatcherMethods
    START_TAG = "${"
    END_TAG   = "}"

    # Removes the tags from the string and returns a new string 
    # without tags.
    #
    # ==== Returns
    # String::
    #   A new string is returned without snippet tags. If the string is just a
    #   regular string and no snippet-tag, nil is retured.
    #
    # ===== Example
    #   "${3:val}".without_tags              # => val
    #   "some ${3:val} string".without_tags  # => nil
    def without_tags
      re = /
        \$\{    # Match the opening of a tag ${
        \d+     # Every tag is followed by a serieses of digits -> e.g. ${1
        :?      # Extended tags have a ':' before the text. normal tags haven't
        (.*)    # Extended Tags now have a series of text, which we want to 
                # extract
        \}      # The closing tag
      /xm
      self.match(re)[1]
    end

    # Returns the opening tag of the snippet.
    #
    # ==== Returns
    # String::
    #   A new string is returned, which includes only the opening tag including
    #   the digit of the snippet-tag.
    #
    # ===== Example
    #   "${3:val}".start_tag                 # => "${3:"
    #   "some ${3:val} string".start_tag     # => nil
    def start_tag
      self.match(/
        (\$\{         # The regular starting sequence of one of our tags: ${
        \d+           # Every tag must have a number after the opening: ${12
        :?)           # Only extended tags _might_ include a ':': ${12:
      /xm)[0]
    end

    # Returns the digit within the tag
    #
    # ==== Returns
    # String::
    #   A new string is returned, which includes only the digit of the tag.
    #
    # ===== Example
    #   "${3:val}".digit_tag                 # => "3"
    #   "some ${3:val} string".digit_tag     # => nil
    def digit_tag
      self.match(/
        \$\{         # The regular starting sequence of one of our tags: ${
        (\d+)        # Every tag must have a number after the opening: ${12
        :?           # Only extended tags _might_ include a ':': ${12:
      /xm)[1]
    end

    def single_tag?
      without_tags == ""
    end

    def scan_snippets
      with_scaned_snippets do |elements|
        elements.map do |element|
          start, stop = element
          self[start, stop - start + 1] rescue self[start, self.size]
        end.flatten
      end
    end

    def scan_snippets_positions
      with_scaned_snippets
    end

    def with_scaned_snippets
      parsed = Parser.new(self).parse
      if block_given?
        yield parsed
      else
        parsed
      end
    end
  end

  def self.included(klass)
    klass.extend(GeditSnippetMatcherGroupMethods)
    klass.send(:include, GeditSnippetMatcherMethods)
  end
end
