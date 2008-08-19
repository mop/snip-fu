require File.dirname(__FILE__) + '/../../spec_helper'

describe TagHistory do
  before(:each) do
    @history = TagHistory.new
  end

  it "should allow to initialize the object" do
    @history = TagHistory.new('tag', 10, 1)
    @history.last_tag.should == 'tag'
    @history.line_number.should == 10
    @history.start_pos.should == 1
  end

  it "should allow to store the last tag" do
    @history.last_tag = 'tag'
    @history.last_tag.should == 'tag'
  end
  
  it "should allow to store the last line number" do
    @history.line_number = 10
    @history.line_number.should == 10
  end

  it "should allow to store the position" do
    @history.start_pos = 10
    @history.start_pos.should == 10
  end

  it "should allow to store the yank-buffer" do
    @history.yank = "yank"
    @history.yank.should == "yank"
  end

  describe "which has some information" do
    before(:each) do
      @history.last_tag     = 'tag'
      @history.line_number  = 10
      @history.start_pos    = 10
      @history.was_restored = true
      @history.yank         = 'yank'
    end

    it "should have no information after calling clear" do
      @history.clear
      @history.last_tag.should be_nil
      @history.line_number.should be_nil
      @history.start_pos.should be_nil
      @history.was_restored?.should be_nil
      @history.yank.should be_nil
    end

    describe "which is cleared" do
      before(:each) do
        @history.clear
      end

      it "should return true on cleared?" do
        @history.should be_cleared
      end
    end
  end
end
