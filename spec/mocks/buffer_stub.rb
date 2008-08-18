# this class is a stub for the VIM-buffer
class BufferStub
  attr_accessor :contents, :current_line
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
    @contents[pos - 1] = val
  end

  # Returns the current line of the buffer
  #
  # ==== Returns
  # String::
  #   The current line is returned as String.
  def line
    self[@current_line]
  end

  # Modifies the current line
  #
  # ==== Parameters
  # val<String>::
  #   The new value for the current line
  def line=(val)
    self[@current_line] = val
  end

  # Appends a new line in the given position with the given value
  #
  # ==== Parameters
  # num<Fixnum>::
  #   Indicates the line number, after which the buffer should be appended
  # str<String>::
  #   Indicates the new value of the line
  def append(num, str)
    @contents.insert(num, str)
  end

  # Returns the current line number
  #
  # ==== Returns
  # Fixnum::
  #   The current line number is returned
  def line_number
    @current_line
  end

  # Returns the size of all lines
  #
  # ==== Returns
  # Fixnum::
  #   The count of the lines is returned.
  def count
    @contents.size
  end

  # Deletes the given line number
  #
  # ==== Parameters
  # num<Fixnum>::
  #   The line number which should be deleted
  def delete(num)
    @contents.delete_at(num - 1)
  end
end
