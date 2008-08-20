# This class represents the VI-window
class WindowStub
  attr_accessor :cursor
  # Initializes the stub
  #
  # ==== Parameters
  # cursor_line<Integer>::
  #   Initializes the cursor with the appropriate line
  # cursor_col<Integer>::
  #   Represents the column of the cursor.
  def initialize(cursor_line, cursor_col)
    @cursor = [cursor_line, cursor_col]
  end
end
