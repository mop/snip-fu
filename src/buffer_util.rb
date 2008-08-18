# This module is monkeypatched into the VIM-Buffer-class and it provides many
# helper-methods for dealing with the buffer.
module BufferUtil
	module ClassMethods
	end
	
	module InstanceMethods
    # Converts the given match to the start-line-number in the Vi-buffer.
    # 
    # ==== Parameters
    # match<String>::
    #   Is a string which contains a matched tag e.g.: ${1:a tag}
    #
    # ==== Returns
    # Fixnum::
    #   Indicates the start-line of the expression in the buffer stream
    #
    # ==== Example
    #   # Buffer-stream contains "some\nlines with ${1:a\ntag}"
    #   # Buffer-array contains ["some", "lines", "with", "${1:a", "tag}"]
    #   #                          /\       /\      /\        /\     /\
    #   # Positions:               1        2       3         4      5
    #   to_line_number("${1:a\ntag}")
    #   # => 4
		def to_line_number(match)
      idx = buffer_lines.index(match)
      buffer_line_cycle.each do |line_number|
        idx -= self[line_number].size
        break line_number if idx <= 0
        idx -= 1   # \n
      end rescue nil
    end

    # Returns the buffer-lines beginning at the current line number, until the
    # end and from the beginning to the current line number.
    # If we are e.g. on line number 3 and the buffer has e.g. 5 lines the
    # following line-numbers are returned [3, 4, 5, 1, 2].
    #
    # ==== Returns
    # Array[Fixnum]::
    #   A list of line-number is returned.
    def buffer_line_cycle
      ((line_number..count).to_a + 
      (1..line_number).to_a).uniq
    end

    # Maps the buffer_line_cycle-array to it's corresponding lines and joins 
    # them with "\n", so that a buffer stream is basically returned, starting 
    # on the current line position.
    #
    # ==== Returns 
    # String::
    #   The lines in the buffer are returned as a string-stream
    def buffer_lines
      buffer_line_cycle.map { |i| self[i] }.join("\n")
    end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end
