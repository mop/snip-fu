require 'snippet'
require 'rexml/document'

# This class is responsible for loading all sorts of snippets and grouping them
# per filetype.
class SnippetLoader
  include REXML
  attr_accessor :snippets

  # Initializes the SnippetLoader
  def initialize
    @snippets = Hash.new do |hash, key|
      hash[key] = []
    end
  end

  # Loads the snippets from the snippet-path.
  # The snippet path is $HOME/.vim/snippets/.
  # The method modifies the @snippets-hash and includes all snippets.
  # Before loading the snippets the @snippets-hash is cleared, so you might use
  # this method to reaload all snippets.
  # ---
  # @public
  def load_snippets
    @snippets = new_snippet_hash
    files.each do |file|
      parse_file(file) rescue nil
    end
  end

  # Returns a list of snippets for the given filetype
  #
  # ==== Parameters
  # key<String>::
  #   The filetype, whose snippets should be returned.
  #
  # ==== Returns
  # Array<Snippet>::
  #   A list of snippets for the given filetype is returned.
  # ---
  # @public
  def [](key)
    @snippets[key]
  end

  # Returns the current active snippets based upon the opened buffer.
  #
  # ==== Returns
  # Array<Snippet>::
  #   A list of snippet for the current active filetype is returned.
  def current_snippets
    self[Vim.evaluate('&filetype')]
  end

  private
  # Returns the snippet directory: $HOME/.vim/snippets
  #
  # ==== Returns
  # String:: The snippets directory as string is returned.
  def snippet_directory
    ENV['HOME'] + '/.vim/snippets'
  end

  # Opens the given file-name and parses it and converts it into an snippet
  #
  # ==== Parameters
  # file<String>::
  #   The file which should be parsed.
  def parse_file(file)
    File.open(file) do |f|
      parse_snippet(f.read)
    end
  end

  # Parses the given snippet-string and creates a new snippet
  #
  # ==== Parameters
  # string<String>::
  #   The content of a snippet-xml file
  def parse_snippet(string)
    doc      = Document.new(string)
    filetype = XPath.first(doc, '//filetype').text
    snippet  = Snippet.new(
      XPath.first(doc, '//key').text,
      XPath.first(doc, '//command').text
    )
    begin
      @snippets[filetype] << snippet
    rescue => e
      p e
    end
  end

  # Returns an array of all files in the snippet-directory
  #
  # ==== Returns
  # Array<String>::
  #   A list of files is returned.
  def files
    Dir[snippet_directory + '/**/*.xml']
  end

  # Returns a hash which returns on new keys an empty array
  #
  # ==== Returns
  # Hash::
  #   A hash is returned, which can be used as snippet-hash
  def new_snippet_hash
    Hash.new do |hash, key|
      hash[key] = []
    end
  end
end

