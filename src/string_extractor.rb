# Extracts a string-stream out of the given buffer.
class StringExtractor
  attr_accessor :buffer, :start, :end
  attr_accessor :start_line, :start_pos, :end_line, :end_pos
  # Initializes the object
  #
  # ==== Parameters
  # buffer<Vim::Buffer>::
  #   The Vi-Buffer, from which the string should be extracted.
  # start<Array[Fixnum, Fixnum]>::
  #   The start-position (line, col).
  # end<Array[Fixnum, Fixnum]>::
  #   The end-position (line, col).
  # --- 
  # @public
  def initialize(buffer, start, e)
    @buffer = buffer
    @start  = start
    @end    = e

    @start_line = @start[0]
    @start_pos  = @start[1]
    @end_line   = @end[0]
    @end_pos    = @end[1]
  end

  # Extracts the string out of the buffer and returns it
  #
  # ==== Returns
  # String::
  #   A string is returned.
  # --- 
  # @public
  def extract_string
    if single_line?
      line = buffer[start_line]
      return line[start_pos, end_pos - start_pos]
    end
    result = first_line
    each_subline { |line| result += line + "\n" }
    result += last_line
  end

  private
  # Returns true if there is only a single line to extract
  def single_line?
    start_line == end_line
  end

  # Yields a block for each line between the start and end-line
  def each_subline
    ((start_line + 1)...end_line).each do |i|
      yield buffer[i]
    end
  end

  # Extracts the end line of the buffer
  #
  # ==== Returns
  # String::
  #   A string which contains the end line is returned
  def last_line
    line = buffer[end_line]
    line[0, end_pos] 
  end

  # Extracts the first line of the buffer
  #
  # ==== Returns
  # String::
  #   A string is returned with the extracted first line.
  def first_line
    line = buffer[start_line]
    line[start_pos, line.size] + "\n"
  end
end
