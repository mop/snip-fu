require 'matcher'
require 'inserter'

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
    last_word == @key
  end
  
  # Inserts the snippet on the cursor-position. If the command is multiple
  # lines long, lines will be appended to the buffer.
  # ---
  # @public
  def insert_snippet
    after       = after_command
    buffer.line = first_command_line

    splitted_command[1..splitted_command.size].reverse.
      each_with_index do |c, i| 

      c = "#{c}#{after}" if i == 0
      buffer.append(buffer.line_number, "#{tab_prefix}#{c}")
    end
  end

  private
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
    @splitted_command ||= @command.split("\n")
  end

  # Returns the first line of the command, inserted into the vi-buffer, is
  # returned. It should be assigned to the vi-buffer.
  # If the command is a multiline-command, the string after the command is
  # discarded.
  #
  # ==== Returns
  # String::
  #   The first line of the command, inserted into the vi-buffer is returned.
  def first_command_line
    str = buffer.line.dup
    if multiline?
      str[last_word_start, str.size]  = splitted_command.first
    else
      str[last_word_start, @key.size] = splitted_command.first
    end
    str
  end

  # Returns the string after the command in the first line
  # ==== Returns
  # String::
  #   A string is returned which contains the string after the command in the
  #   first line.
  def after_command
    buffer.line[cursor_column, buffer.line.size]
  end

  # Returns true if the command is a multiline command
  #
  # ==== Returns
  # Bool::
  #   True if the command is multiple lines long, otherwise false.
  def multiline?
    splitted_command.size > 1
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

