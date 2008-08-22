require File.dirname(__FILE__) + '/../../spec_helper'

describe StringExtractor do
  describe 'extraction of simple strings' do
    before(:each) do
      @buffer = BufferStub.new("something")
    end

    it 'should extract the correct string' do
      StringExtractor.new(@buffer, [1, 2], [1, 4]).extract_string.should eql(
        "me"
      )
    end
  end

  describe 'extraction of multiline strings' do
    before(:each) do
      @buffer = BufferStub.new("some\nthing\nwith\nmultiple\nlines")
    end

    it 'should extract the correct string' do
      StringExtractor.new(@buffer, [1, 2], [3, 4]).extract_string.should eql(
        "me\nthing\nwith"
      )
    end
  end

  describe "extraction of parts with only newlines" do
    before(:each) do
      @buffer = BufferStub.new("\n\n\n\nend")
    end

    it "should extract them without problems" do
      StringExtractor.new(@buffer, [1, 1], [5, 3]).extract_string.should eql(
        "\n\n\n\nend" 
      )
    end
  end
end
