module ManipulatorHelper 
	module ClassMethods
	end
	
	module InstanceMethods
    attr_accessor :window, :buffer 
		def initialize(window=nil, buffer=nil)
      @window = window
      @buffer = buffer
    end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end
