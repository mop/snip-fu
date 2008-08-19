require File.dirname(__FILE__) + '/../../spec_helper'

describe TagHistory do
  before(:each) do
    @history = TagHistory.new
  end
  it "should allow to store the last tag" do
    @history.last_tag = 'tag'
  end
  
  it "should allow to store the last line number" do
    @history.line_number = 10
    @history.line_number.should == 10
  end

  it "should allow to store the positionce" do
    @history.start_pos = 10
    @history.start_pos.should == 10
  end

  describe "a TagHistory object with some informationce" do
    before(:each) do
      
    end

    it "should have no information after calling clear" do
      
    end
  end
end
