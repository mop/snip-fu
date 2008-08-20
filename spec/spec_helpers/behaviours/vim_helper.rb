module VimSpecHelper 
	module ClassMethods
	end
	
	module InstanceMethods
		def stub_vim
      Object.send(:remove_const, :Vim) rescue nil
      Object.const_set(:Vim, stub_everything)
      Vim.instance_eval do
        def command(arg)
          @commands ||= []
          @commands << arg
        end

        def received_commands
          @commands
        end

        def evaluate(arg)
          @evaluates ||= []
          @evaluates << arg
          'yank'
        end

        def received_evaluates
          @evaluates
        end
      end
    end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end
