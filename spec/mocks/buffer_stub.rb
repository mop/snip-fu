# this class is a stub for the VIM-buffer
class BufferStub
  attr_accessor :contents
  def initialize(contents, current_line=1)
    @contents = contents.split("\n")
    @current_line = current_line
  end

  # This method returns the given line
  # 
  # ==== Parameters
  # pos<Fixnum>::
  #   Inidicates the index in the array. The index starts actually at 1 and
  #   goes until the size of the buffer.
  #
  # ==== Returns
  # String::
  #   The appropriate line is returned
  def [](pos)
    @contents[pos - 1]
  end
  
  # Modifies the selected line
  #
  # ==== Parameters
  # pos<Fixnum>::
  #   The position in the buffer, which should be modified. The position starts
  #   actually at 1.
  # val<String>::
  #   The new value of the line.
  def []=(pos, val)
    @contents[pos - 1, val]
  end

  # Returns the current line of the buffer
  #
  # ==== Returns
  # String::
  #   The current line is returned as String.
  def line
    self[@current_line]
  end
end
