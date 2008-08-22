require "ostruct"
require "fileutils"

# This file records all actions of the user and then invokes vim, executes the
# recorded commands and closes vim. The contents of the buffer will be returned
# to the user.
#
# ==== Example
#
# invoker = VimInvoker.new("/tmp/vim-spec-home")
# invoker.insert_string("def")
# invoker.tab
# invoker.tab
# invoker.execute!
# # => "def method_name\n  \nend\n"
class VimInvoker
  attr_accessor :file_extension
  # Initializes the invoker with the given stubbed home-directory
  #
  # ==== Parameters
  # home<String>::
  #   The stubbed home-directory in which the temporare file should be created.
	def initialize(home)
  	@commands       = ""
    @file_extension = ".rb"
    @home           = home
  end

  # Inserts the given string into the buffer
  #
  # ==== Parameters
  # str<String>::
  #   The string, which should be inserted into the buffer.
  def insert_string(str)
  	@commands += str
  end

  # Inserts a tab into the buffer
  def tab
  	@commands += "\\<Tab>"
  end

  # Executes vim with the recorded commands and writes it's buffer into a file
  # whose contents are returned.
  #
  # ==== Returns
  # String::
  #   A string with the final buffer-content is returned.
  def execute!
  	system("vim #{file} -c 'execute \"normal i#{escaped_commands}\\<Esc>\"' -c 'execute \":wq\"'")
    File.read(file)
  end

  private
  def escaped_commands
  	@commands.gsub('"', '\"')
  end

  def file
  	"#{@home}/testfile#{@file_extension}"
  end
end

module VimIntegrationHelper
	module ClassMethods
	end
	
	module InstanceMethods
    # Yields a block with a VimInvoker-object which should be used to make
    # integration tests with vim. It creates a stubbed home-directory in
    # /tmp/vim-spec-home, creates the .vimrc file and copies the src-directory
    # of the project into it. It also temporarely stubs the HOME-environment
    # variable with the new home-directory. The user can now record a few
    # commands with the vim-invoker object and then call execute! on it to see
    # the result of the buffer.
    #
    # ==== Example
    # with_vim do |vim|
    #   vim.insert_string("def")
    #   vim.tab
    #   vim.tab
    #   vim.execute!.should == "def method_name\n  \nend\n"
    # end
		def with_vim
      begin
        stub_home
        create_home
        vim = VimInvoker.new(new_home_directory)
        yield vim
      ensure
        restore_home
      end
    end

    # Stubs the home directory
    def stub_home
      @original_home = ENV["HOME"]
    	ENV["HOME"] = new_home_directory
    end

    # Removes the stubbed home directory and restores the original
    # home-directory.
    def restore_home
      FileUtils.rm_rf(new_home_directory)
    	ENV['HOME'] = @original_home
    end

    # Creates the stubbed home-directory
    def create_home
      create_dirs
      copy_files
      create_vimrc
    end

    def create_dirs
      FileUtils.mkdir_p([snip_fu_directory, snippets_directory])
    end

    def create_vimrc
      File.open("#{new_home_directory}/.vimrc", "w") do |io|
        io.puts <<-EOF
autocmd Filetype ruby,eruby,yaml set ai sw=2 sts=2 ts=2 et
autocmd Filetype python,py set ai sw=4 ts=4
rubyf #{snip_fu_directory + '/vim-snippet.rb'}
        EOF
      end
    end

    def copy_files
    	FileUtils.cp_r(snip_fu_src, snip_fu_directory)
    	FileUtils.cp_r(snip_fu_share, snippets_directory)
    end

    def new_home_directory
    	"/tmp/vim-spec-home"
    end

    def new_vim_directory
    	new_home_directory + '/.vim'
    end

    def snip_fu_directory
    	new_vim_directory + '/snip_fu'
    end

    def snippets_directory
    	new_vim_directory + '/snippets'
    end

    def snip_fu_src
    	File.dirname(__FILE__) + '/../../../src/.'
    end

    def snip_fu_share
    	File.dirname(__FILE__) + '/../../../share/.'
    end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end
