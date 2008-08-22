require File.dirname(__FILE__) + '/../spec_helper'

describe Snippet, 'pressed?' do
  include SnippetSpecHelper
  before(:each) do
    @snippet = fetch_snippet(:for)
  end

  it 'should return true for pressed?' do
    @snippet.should be_pressed
  end

  describe 'when modifying the cursor position' do
    before(:each) do
      @snippet.instance_variable_set(:@window, WindowStub.new(1, 1))
    end

    it 'should not be pressed anymore' do
      @snippet.should_not be_pressed
    end
  end

  describe 'when modifying the buffer' do
    before(:each) do
      @snippet.instance_variable_set(:@buffer, BufferStub.new("while"))
    end
    
    it 'should not be pressed anymore' do
      @snippet.should_not be_pressed
    end
  end

  describe 'when having some letters before the snippet' do
    before(:each) do
      @snippet.instance_variable_set(:@buffer, BufferStub.new("somethingfor"))
      @snippet.instance_variable_set(:@window, WindowStub.new(1, 12))
    end

    it 'should not be pressed anymore' do
      @snippet.should_not be_pressed
    end
  end

  describe 'when having some letters after the snippet' do
    before(:each) do
      @snippet.instance_variable_set(:@buffer, BufferStub.new("forsomething"))
      @snippet.instance_variable_set(:@window, WindowStub.new(1, 3))
    end

    it 'should not be pressed anymore' do
      @snippet.should_not be_pressed
    end
  end
end

describe Snippet, 'insert multi line snippets' do
  include SnippetSpecHelper
  include VimSpecHelper
  before(:each) do
    stub_vim
    Vim.stub!(:command).and_return(' ')
    Vim.stub!(:evaluate).and_return(' ')
    @buffer = BufferStub.new("for")
    @snippet = fetch_snippet(:for, @buffer)
  end

  it 'should insert the snippet correctly' do
    @snippet.insert_snippet
    @buffer.contents[0].should eql("for ${0:key} in ${1:vals}")
    @buffer.contents[1].should eql("${2}")
    @buffer.contents[2].should eql("end")
    @buffer.contents[3].should eql("${3}")
  end

  it 'should move other things in the buffer correctly' do
    @buffer.line = "for other"
    @snippet.insert_snippet
    @buffer.contents[0].should eql("for ${0:key} in ${1:vals}")
    @buffer.contents[1].should eql("${2}")
    @buffer.contents[2].should eql("end")
    @buffer.contents[3].should eql("${3} other")
  end
end

describe Snippet, 'insert single line snippets' do
  include SnippetSpecHelper
  before(:each) do
    @buffer = BufferStub.new("aftp")
    @snippet = fetch_snippet(:aftp, @buffer)
  end

  it 'should insert the snippet correctly' do
    @snippet.insert_snippet
    @buffer.contents[0].should eql(
      "after Proc.new { |c| ${1:c.some_method} }${2:, :${10:only} =&gt; ${11:[${12::login, :signup}]}}"
    )
  end

  it 'should move other things in the buffer correctly' do
    @buffer.line = "aftp other"
    @snippet.insert_snippet
    @buffer.contents[0].should eql(
      "after Proc.new { |c| ${1:c.some_method} }${2:, :${10:only} =&gt; ${11:[${12::login, :signup}]}} other"
    )
  end
end

describe Snippet, 'insert tabs' do
  include SnippetSpecHelper
  include VimSpecHelper
  before(:each) do
    stub_vim
    Vim.stub!(:evaluate).with('&expandtab').and_return('1')
    Vim.stub!(:command)
    Vim.stub!(:evaluate).with('tabs').and_return('1')
    Vim.stub!(:evaluate).with('tabstr').and_return('  ')
    @buffer = BufferStub.new('for')
    @snippet = fetch_snippet(:for, @buffer)
  end

  it 'should indent the command correctly' do
    @snippet.insert_snippet
    @buffer.contents[0].should eql('for ${0:key} in ${1:vals}')
    @buffer.contents[1].should eql('  ${2}')
    @buffer.contents[2].should eql('  end')
    @buffer.contents[3].should eql('  ${3}')
  end

  describe 'with tabs as stop' do
    before(:each) do
      Vim.stub!(:evaluate).with('&expandtab').and_return('0')
      Vim.stub!(:command)
      Vim.stub!(:evaluate).with('tabs').and_return('1')
    end

    it 'should indent the command correctly' do
      @snippet.insert_snippet
      @buffer.contents[0].should eql('for ${0:key} in ${1:vals}')
      @buffer.contents[1].should eql("\t${2}")
      @buffer.contents[2].should eql("\tend")
      @buffer.contents[3].should eql("\t${3}")
    end
  end
end

describe Snippet, 'with other tags' do
  include SnippetSpecHelper
  include VimSpecHelper

  before(:each) do
    stub_vim
    SnipFu::Config[:start_tag] = '$['
    SnipFu::Config[:end_tag]   = ']'

    @buffer = BufferStub.new("for")
    @snippet = fetch_snippet(:for, @buffer)
  end

  after(:each) do
    SnipFu::Config[:start_tag] = '${'
    SnipFu::Config[:end_tag]   = '}'
  end

  it 'should insert the snippet with replaced tags' do
    @snippet.insert_snippet
    @buffer.contents[0].should == 'for $[0:key] in $[1:vals]'
    @buffer.contents[1].should == '$[2]'
    @buffer.contents[2].should == 'end'
    @buffer.contents[3].should == '$[3]'
  end
end
