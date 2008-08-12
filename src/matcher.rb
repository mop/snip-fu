require 'parser'
module GeditSnippetMatcher
  module GeditSnippetMatcherGroupMethods
  end

  module GeditSnippetMatcherMethods
    START_TAG = "${"
    END_TAG   = "}"

    def without_tags
      self.match(/\$\{\d+:?(.*)\}/)[1]
    end

    def single_tag?
      without_tags == ""
    end

    def scan_snippets
      with_scaned_snippets do |elements|
        elements.map do |element|
          start, stop = element
          self[start, stop - start + 1]
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
