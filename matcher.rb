module GeditSnippetMatcher
  module GeditSnippetMatcherGroupMethods
  end

  module GeditSnippetMatcherMethods
    START_TAG = "${"
    END_TAG   = "}"

    def scan_snippets
      copy  = self.dup
      result = []

      while copy.snippet_index(START_TAG)
        idx_start = copy.snippet_index(START_TAG)
        idx_end   = copy.snippet_index(END_TAG)
        tmp = copy[idx_start, idx_end - idx_start + END_TAG.length]

        while tmp.start_snippet_count != tmp.end_snippet_count
          idx_end = copy.nth_snippet_end_index(tmp.start_snippet_count)
          tmp = copy[idx_start, idx_end - idx_start + END_TAG.length]
        end
        
        result << copy[idx_start, idx_end - idx_start + 1 ]
        copy = copy[idx_end + END_TAG.length, copy.size]
      end
      result
    end

    def nth_snippet_end_index(num)
      idx = 0
      str = self.dup
      num.times do
        idx += str.snippet_index(END_TAG)    + END_TAG.size
        str = str[str.snippet_index(END_TAG) + END_TAG.size, str.size]
      end
      idx - END_TAG.size
    end

    def snippet_index(snip)
      idx = self.index(snip)
      return nil if idx.nil?
      while self[idx - 1] == "\\"[0]
        copy = self[idx + 1, self.size]
        idx  += copy.index(snip) + 1
      end
      idx
    end

    def end_snippet_count
      scan(END_TAG).count - scan("\\#{END_TAG}").count
    end

    def start_snippet_count
      scan(START_TAG).count - scan("\\#{START_TAG}").count
    end
  end

  def self.included(klass)
    klass.extend(GeditSnippetMatcherGroupMethods)
    klass.send(:include, GeditSnippetMatcherMethods)
  end
end
