module SnippetSpecHelper  
	module ClassMethods
		
	end
	
	module InstanceMethods
		def fetch_snippet(sym, buffer=nil)
    	self.send("snippet_#{sym}", buffer)
    end

    def snippet_for(buffer=nil)
      Snippet.new(
        "for",
        "for ${0:key} in ${1:vals}\n${2}\nend\n${3}",
        WindowStub.new(1, 3),
        buffer || BufferStub.new("for")
      )
    end

    def snippet_aftp(buffer=nil)
      Snippet.new(
        "aftp",
        "after Proc.new { |c| ${1:c.some_method} }${2:, :${10:only} =&gt; ${11:[${12::login, :signup}]}}",
        WindowStub.new(1, 4),
        buffer || BufferStub.new('aftp')
      )
    end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end
