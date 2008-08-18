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
      )
    ]
  end
end
