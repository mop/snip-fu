require 'snippet'
require "rubygems"
require "ruby-debug"

# This class is responsible for loading all sorts of snippets and grouping them
# per filetype.
class SnippetLoader
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
  #
  # ==== Parameters
  # type<String>::
  #   The filetype which should be loaded by snip-fu. If the type is nil all
  #   snippets will be loaded.
  # ---
  # @public
  def load_snippets(type=nil)
    @snippets = new_snippet_hash
    files(type).each do |file|
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
    load_snippets(key) if @snippets[key].empty?
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
    filetype = string.scan(/<filetype>(.*?)<\/filetype>/m)[0][0]
    snippet = Snippet.new(
      string.scan(/<key>(.*?)<\/key>/m)[0][0],
      string.scan(/<command>(.*?)<\/command>/m)[0][0]
    )
    @snippets[filetype] << snippet
  end

  # Returns an array of all files in the snippet-directory
  #
  # ==== Parameters
  # type<String>::
  #   The filetype which should be loaded by snip-fu. If the type is nil all
  #   snippets will be loaded.
  #
  # ==== Returns
  # Array<String>::
  #   A list of files is returned.
  def files(type=nil)
    type += '/**' if type
    type ||= '**'
    Dir[snippet_directory + "/#{type}/*.xml"]
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
