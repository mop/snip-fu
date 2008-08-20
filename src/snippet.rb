require 'matcher'
require 'inserter'
require 'command_formatter'

# This class represents a Snippet
class Snippet
  attr_accessor :key, :command, :buffer, :window
  def initialize(
    key,
    command,
    window=Vim::Window.current,
    buffer=Vim::Buffer.current
  )

    @key     = key
    @command = command
    @window  = window
    @buffer  = buffer
  end

  # Returns true if the snippet was entered as last word.
  #
  # ==== Returns
  # True if the snippet should be activated.
  # ---
  # @public
  def pressed?
    last_word == @key && position_valid?
  end
  
  # Inserts the snippet on the cursor-position. If the command is multiple
  # lines long, lines will be appended to the buffer.
  # ---
  # @public
  def insert_snippet
    remove_key
    insert_string = CommandFormatter.new(@command).format
    StringInserter.new(
      @buffer,
      insert_string.gsub("\n", "\n#{tab_prefix}"),
      [ window.cursor[0], last_word_start ]
    ).insert_string
  end

  private
  # Removes the pressed key-word from the buffer.
  def remove_key
    str = @buffer.line
    str[last_word_start, @key.size] = ""
    @buffer.line = str
  end

  # Returns the window-buffer
  #
  # ==== Returns
  # Vim::Buffer::
  #   The current buffer is returned.
  def buffer
    @buffer
  end

  # Returns the splitted command after \n
  #
  # ==== Returns
  # Array[String]::
  #   The snippet-command is returned, splittet with \n to insert the lines
  #   into the vi-buffer.
  def splitted_command
    @command.split("\n")
  end

  # Returns the last "word" in the vi-buffer
  #
  # ==== Returns
  # String::
  #   A string is returned which contains the last word in the vi-buffer
  def last_word
    buffer.line[last_word_start, @key.size]
  end

  # Returns the column of the cursor
  #
  # ==== Returns
  # Fixnum::
  #   The column-position of the cursor is returned.
  def cursor_column
    line, col = @window.cursor
    col
  end

  # Returns the position on which the last 'word' in the buffer starts.
  #
  # ==== Returns
  # Fixnum::
  #   The position is returned as Fixnum.
  def last_word_start
    cursor_column - @key.size 
  end

  # Returns true if before the actual key-word is no alphanumeric character
  #
  # ==== Returns
  # Bool::
  #   True if there is no alphanumeric character before the key-word in the
  #   buffer.
  def position_valid?
    pos_valid?(last_word_start - 1) && 
    pos_valid?(cursor_column)
  end

  # Returns true if the given position is valid
  #
  # ==== Returns
  # Bool::
  #   True if there is no alphanumeric character before the key-word in the
  #   buffer.
  def pos_valid?(pos)
    return true if buffer.line.size <= pos || pos < 0
    (buffer.line[pos].chr =~ /[a-zA-Z0-9]/).nil?
  end

  # Returs the tab-prefix for the current line, which should be inserted 
  # in multi-line snippets.
  #
  # ==== Returns
  # String::
  #   A string is returned which should be used to "prefix" newly inserted
  #   lines
  def tab_prefix
    if Vim.evaluate('&expandtab') == '1'
      Vim.command('let tabs = indent(".")/&shiftwidth')
      tabs = Vim.evaluate('tabs').to_i
      Vim.command('let tabstr = repeat(" ",&shiftwidth)')
      tabstr = Vim.evaluate('tabstr')
    else
      Vim.command('let tabs = indent(".")/&tabstop')
      tabs = Vim.evaluate('tabs').to_i
      tabstr = "\t"
    end
    tabstr * tabs rescue ''
  end
end

