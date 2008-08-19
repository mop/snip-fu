require File.dirname(__FILE__) + '/../spec_helper'

describe "A BufferManager when jumping" do
  describe "when handling a nested def" do
    before(:each) do
      Vim = stub_everything
      @buffer = BufferStub.new("def")
      @window = WindowStub.new(1, 3)
      SnippetLoader.stub!(:new).and_return(snippet_loader_mock)
      @buffer_manager = BufferManager.new(@window, @buffer)
    end

    it "should insert two tags in a row correctly" do
      @buffer_manager.handle_insert
      @buffer_manager.jump

      @buffer[1].should == "def method_name"
      @buffer[1] = "def def"

      @window.cursor = [ 1, 7 ]
      @buffer_manager.buffer = @buffer
      @buffer_manager.window = @window

      @buffer_manager.handle_insert
      @buffer_manager.jump

      @buffer[1].should == "def def method_name"
    end
  end

  describe "when handling an it from rspec-bundle" do
    before(:each) do
      Vim = stub_everything
      @buffer = BufferStub.new("it")
      @window = WindowStub.new(1, 2)
      SnippetLoader.stub!(:new).and_return(snippet_loader_mock)
      @buffer_manager = BufferManager.new(@window, @buffer)
    end

    it "should step through the it correctly" do
      @buffer_manager.handle_insert
      @buffer_manager.jump
      @buffer[1].should == "it \"should ${1:description}\" ${3:do"
      @window.cursor = [1, 5]
      @buffer_manager.jump
      @buffer[1].should == "it \"should description\" ${3:do"
      @window.cursor = [1, 12]
      @buffer_manager.jump
      @buffer[1].should == "it \"should description\" do"
      @buffer[2].should == "  ${0}"
      @buffer[3].should == "end"
      @buffer[4].should == nil 
      @buffer[5].should == nil 
    end
  end

  describe "when handling a big insertion at the end" do
    before(:each) do
      Vim = stub_everything
      i = (1..100).map { |i| "\n" }.join("")
      @buffer = BufferStub.new("#{i}def", 101)
      @window = WindowStub.new(101, 3)
      SnippetLoader.stub!(:new).and_return(snippet_loader_mock)
      @buffer_manager = BufferManager.new(@window, @buffer)
    end

    it "should jump to the correct position" do
      @buffer_manager.handle_insert
      @buffer_manager.jump
      @buffer[101].should == "def method_name"
      @window.cursor = [103, 3]
      @buffer.current_line = 103
      @buffer_manager.jump
      @buffer[102].should == "  "
    end
  end

  describe "when handling multiline insertions with indentation" do
    before(:each) do
      Vim = stub_everything
      @buffer = BufferStub.new(
        "  it \"should description\" ${3:do\n    ${0}\n  end}"
      )
      @window = WindowStub.new(1, 4)
      SnippetLoader.stub!(:new).and_return(snippet_loader_mock)
      @buffer_manager = BufferManager.new(@window, @buffer)
    end

    it "should expand the multiline tag correctly" do
      @buffer_manager.jump
      @buffer[2].should == "    ${0}"
    end
  end

  describe "when applying transformations to tags" do
    before(:each) do
      Vim = stub_everything
      @buffer = BufferStub.new(
        "for"
      )
      @window = WindowStub.new(1, 3)
      SnippetLoader.stub!(:new).and_return(snippet_loader_mock)
      @buffer_manager = BufferManager.new(@window, @buffer)
    end

    it 'should transform the snippet correctly' do
      @buffer_manager.handle_insert
      @buffer_manager.jump
      @buffer[1].should == "for #{ENV['HOME']} in ${2:val}"
      @buffer[1] = "for  in ${2:val}"   # Check if restoration works
      @window.cursor = [1, 4]
      @buffer_manager.buffer = @buffer
      @buffer_manager.window = @window
      @buffer_manager.handle_insert
      @buffer_manager.jump
      @buffer[1].should == "for #{ENV['HOME']} in val"
    end
  end

  describe "when jumping to a tag after an translation tag" do
    before(:each) do
      Vim = stub_everything
      @buffer = BufferStub.new(
        "tim"
      )
      @window = WindowStub.new(1, 3)
      SnippetLoader.stub!(:new).and_return(snippet_loader_mock)
      @buffer_manager = BufferManager.new(@window, @buffer)
    end

    it 'should jump to the correct tag' do
      @buffer_manager.handle_insert
      @buffer_manager.jump
      @buffer[1].should == "times { ${1/(^(?<var>\s*(?:\*|\*?[a-z_])[a-zA-Z0-9_]*\s*)(,\g<var>)*,?\s*$)|.*/(?1:|)/}n${1/(^(?<var>\s*(?:\*|\*?[a-z_])[a-zA-Z0-9_]*\s*)(,\g<var>)*,?\s*$)|.*/(?1:| )/}${0} }"
    end
  end

  def snippet_loader_mock
    @loader ||= create_snippet_loader
  end

  def create_snippet_loader
    loader = mock('loader')
    loader.stub!(:load_snippets)
    loader.stub!(:[]).and_return(snippets)
    loader.stub!(:current_snippets).and_return(snippets)
    loader
  end

  def snippets
    [
      Snippet.new(
        "def",
        "def ${1:method_name}\n  ${0}\nend",
        @window, @buffer
      ),
      Snippet.new(
        "it",
        "it \"${2:should ${1:description}}\" ${3:do\n  ${0}\nend}",
        @window, @buffer
      ),
      Snippet.new(
        "for",
        "for ${1:${HOME:default}} in ${2:val}",
        @window, @buffer
      ),
      Snippet.new(
        "tim",
        "times { ${1/(^(?<var>\s*(?:\*|\*?[a-z_])[a-zA-Z0-9_]*\s*)(,\g<var>)*,?\s*$)|.*/(?1:|)/}${1:n}${1/(^(?<var>\s*(?:\*|\*?[a-z_])[a-zA-Z0-9_]*\s*)(,\g<var>)*,?\s*$)|.*/(?1:| )/}${0} }",
        @window, @buffer
      )
    ]
  end
end
