require File.dirname(__FILE__) + '/../spec_helper'
describe StringInserter do
  describe 'insertion of simple strings' do
    before(:each) do
      @buffer = BufferStub.new("something")
    end
    
    it 'should insert the string on the correct position' do
      StringInserter.new(@buffer, "newstr", [ 1, 4]).insert_string
      @buffer.contents[0].should eql('somenewstrthing')
    end
  end
  
  describe 'insertion of multi-line strings' do
    before(:each) do
      @buffer = BufferStub.new("something")
    end
    
    it 'should insert the string on the correct position' do
      StringInserter.new(@buffer, "new\nstr", [ 1, 4]).insert_string
      @buffer.contents[0].should eql('somenew')
      @buffer.contents[1].should eql('strthing')
    end
  end

  describe 'insertion into multi-line strings' do
    before(:each) do
      @buffer = BufferStub.new("something\nlast")
    end

    it 'should insert the string on the correct position' do
      StringInserter.new(@buffer, "new\nstr", [1, 4]).insert_string
      @buffer.contents[0].should eql("somenew")
      @buffer.contents[1].should eql("strthing")
      @buffer.contents[2].should eql("last")
    end
  end

  describe 'insertion of edge-cases' do
    before(:each) do
      @buffer = BufferStub.new("something")
    end

    it 'should insert the string on the correct position' do
      StringInserter.new(@buffer, "new\nstr", [1, 9]).insert_string
      @buffer.contents[0].should eql("somethingnew")
      @buffer.contents[1].should eql("str")
    end
  end

  describe 'bugfix' do
    before(:each) do 
      @buffer = BufferStub.new('for  ')
    end

    it 'should insert the string on the correct position' do
      StringInserter.new(@buffer, "key", [1, 5]).insert_string
      @buffer.contents[0].should eql("for  key")
    end
  end
end
