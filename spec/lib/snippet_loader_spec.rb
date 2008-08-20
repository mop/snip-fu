require File.dirname(__FILE__) + '/../spec_helper'

describe 'A snippet loader' do
  include VimSpecHelper
  before(:each) do
    @loader = SnippetLoader.new
  end

  def file_mock
    @file_mock ||= mock('file')
  end

  def for_snippet 
    <<-EOF
<snippet>
  <filetype>ruby</filetype>
  <key>for</key>
  <command>for ${1:command}
  ${0}
end</command>
</snippet>
    EOF
  end

  def rb_def_snippet
    <<-EOF
<snippet>
  <filetype>ruby</filetype>
  <key>def</key>
  <command>def ${1:methodName}
  ${0}
end</command>
</snippet>
    EOF
  end

  def py_def_snippet
    <<-EOF
<snippet>
  <filetype>python</filetype>
  <key>def</key>
  <command>def ${1:methodName}(self${2:params})
  ${0}
end</command>
</snippet>
    EOF
  end
  
	describe 'opening the snippet files' do
    before(:each) do
      File.stub!(:open).and_yield(file_mock)
      Dir.stub!(:[]).with(
        ENV['HOME'] + '/.vim/snippets/**/*.xml'
      ).and_return([:file1, :file2])
    end
    
		it 'should scan the snippets directory' do
      Dir.should_receive(:[]).with(
        ENV['HOME'] + '/.vim/snippets/**/*.xml'
      ).and_return([])
      @loader.load_snippets
    end
    
		it 'should open all snippets files' do
      File.should_receive(:open).with(:file1)
      File.should_receive(:open).with(:file2)
      @loader.load_snippets
    end
    
		it 'should open the next file if an error occured' do
      File.should_receive(:open).with(:file1).and_raise RuntimeError.new
      File.should_receive(:open).with(:file2)
      @loader.load_snippets
    end
	end

	describe 'parsing a snippet file' do
    before(:each) do
      Dir.stub!(:[]).with(
        ENV['HOME'] + '/.vim/snippets/**/*.xml'
      ).and_return([:file1])
      File.stub!(:open).with(:file1).and_yield(StringIO.new(for_snippet))
      Snippet.stub!(:new).and_return(:snippet)
    end
    
		it 'should parse a snippet file correctly' do
      Snippet.should_receive(:new).with('for', "for ${1:command}\n  ${0}\nend")
      @loader.load_snippets
    end
    
		it 'should not create a snippet object on error' do
      File.stub!(:open).and_raise RuntimeError.new
      Snippet.should_not_receive(:new)
      @loader.load_snippets
    end
    
		it 'should group the snippets per filetype' do
      @loader.load_snippets
      @loader.snippets.should ==({ 'ruby' => [ :snippet ] })
    end
	end

	describe 'parsing multiple snippets' do
    before(:each) do
      Dir.stub!(:[]).with(
        ENV['HOME'] + '/.vim/snippets/**/*.xml'
      ).and_return([:file1, :file2, :file3])
      File.stub!(:open).with(:file1).and_yield(StringIO.new(for_snippet))
      File.stub!(:open).with(:file2).and_yield(StringIO.new(rb_def_snippet))
      File.stub!(:open).with(:file3).and_yield(StringIO.new(py_def_snippet))
      Snippet.stub!(:new).with('for', "for ${1:command}\n  ${0}\nend").
        and_return(:snippet1)
      Snippet.stub!(:new).with('def', "def ${1:methodName}\n  ${0}\nend").
        and_return(:snippet2)
      Snippet.stub!(:new).with(
        'def',
        "def ${1:methodName}(self${2:params})\n  ${0}\nend"
      ).and_return(:snippet3)
    end
    
		it 'should be return the snippets for a the filetype using []' do
      @loader.load_snippets
      @loader['ruby'].should eql([:snippet1, :snippet2])
      @loader['python'].should eql([:snippet3])
    end

    it 'should return an empty array without snippets' do
      @loader['ruby'].should eql([])
    end
	end

  describe 'current_snippets method' do
    before(:each) do
      stub_vim
      Vim.stub!(:evaluate).and_return('ruby')
      @snippet_loader = SnippetLoader.new
      @snippet_loader.instance_variable_set(:@snippets, { 
        'ruby' => [ :ruby ] 
      })
    end

    it 'should return the snippets for the current file-type' do
      @snippet_loader.current_snippets.should eql([:ruby])
    end

    it 'should call the correct vim command for getting the filetype' do
      Vim.should_receive(:evaluate).with('&filetype')
      @snippet_loader.current_snippets
    end
  end
end

