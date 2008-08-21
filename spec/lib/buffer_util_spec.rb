require File.dirname(__FILE__) + '/../spec_helper'

describe 'BufferUtil' do
  before(:each) do
    BufferStub.send(:include, BufferUtil)
  end

  describe "to_line_number" do
    it "should return the correct line number for the given mark" do
      buffer = BufferStub.new("something\n\n\n${0}")
      buffer.to_line_number("${0}").should == 4
    end

    it "should handle extended tags" do
      buffer = BufferStub.new("something\n\n\n${0:extended}")
      buffer.to_line_number("${0:extended}").should == 4
    end

    it "should handle lots of newlines correctly" do
      newlines = (1..100).map { |i| "\n" }.join("")
      buffer = BufferStub.new(newlines + "${0}")
      buffer.to_line_number("${0}").should == 101
    end

    it "should return nil if nothing was found" do
      buffer = BufferStub.new("something")
      buffer.to_line_number("${0}").should be_nil
    end
  end

  describe "buffer_line_cycle" do
    it "should return an array including all line-numbers," + 
       " beginning with the current" do
          
      buffer = BufferStub.new("a\na\na\na", 3)
      buffer.buffer_line_cycle.should eql([3, 4, 1, 2])
    end

    it "should work if there is only one line" do
      buffer = BufferStub.new("a")
      buffer.buffer_line_cycle.should eql([1])
    end
  end

  describe "buffer_lines" do
    it "should return the lines as joined string" do
      buffer = BufferStub.new("a\nb\nc")
      buffer.buffer_lines.should eql("a\nb\nc")
    end
  end

  describe "insert_string" do
    it "should use the StringInserter for inserting a string" do
      buffer = BufferStub.new("buffer")
      inserter = mock('inserter')
      StringInserter.should_receive(:new).with(buffer, "teststr", [1, 10]).
        and_return(inserter)
      inserter.should_receive(:insert_string)
      buffer.insert_string('teststr', [1, 10])
    end
  end

  describe "extract_string" do
    it "should use the StringExtractor for extracting a string" do
      buffer = BufferStub.new("buffer")
      extractor = mock('extractor')
      StringExtractor.should_receive(:new).with(buffer, [1, 1], [2, 10]).
        and_return(extractor)
      extractor.should_receive(:extract_string)
      buffer.extract_string([1, 1], [2, 10])
    end
  end
end
