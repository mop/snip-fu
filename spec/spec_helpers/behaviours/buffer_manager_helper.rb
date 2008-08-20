module BufferManagerSpecHelper 
	module ClassMethods
	end
	
	module InstanceMethods
		def inserter_stub(tag)
    	inserter = mock('inserter')
      inserter.stub!(:remove_tags_from_buffer!).and_return(tag)
      inserter.stub!(:key_directions).and_return("")
      inserter.stub!(:start_pos)
      Inserter.stub!(:new).and_return(inserter)
      inserter
    end

    def snippet_stub(hash={})
      snippet = mock('Snippet', hash)
      Snippet.stub!(:new).and_return(snippet)
      snippet
    end

    def loader_stub(snippets)
      loader  = mock('Loader', :current_snippets => snippets)
      loader.stub!(:load_snippets)
      SnippetLoader.stub!(:new).and_return(loader)
      loader
    end

    def history_stub!
      @history = TagHistory.new("${1:key}", 1, 4)
      @manager.instance_variable_set(:@history, @history)
      @cursor_backup = @window.cursor
      @window.cursor = [ 2, 3 ]
    end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end
