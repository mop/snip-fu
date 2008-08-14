require File.dirname(__FILE__) + "/../spec_helper"

describe RegexpHandler do
    
  it 'should recognize and apply regexps in tags' do
    RegexpHandler.new("something SELECTED/^.+$/- $0/g").
      replace.should eql("- something SELECTED")
  end

  it 'should have no problems with {} around numbers' do
    RegexpHandler.new("something SELECTED/^.+$/- ${0}/g").
      replace.should eql("- something SELECTED")
  end

  describe 'upcase' do
    it 'should apply upcase correctly' do
      RegexpHandler.new("something SELECTED/^.+$/- \\u${0}/g").
        replace.should eql("- Something SELECTED")
    end

    it 'should apply big upcase correctly' do
      RegexpHandler.new("something SELECTED/^.+$/- \\U${0}/g").
        replace.should eql("- SOMETHING SELECTED")
    end

    it 'should stop correctly' do
      RegexpHandler.new(
        "something SELECTED/^(some)(thing)(.*)$/- \\U${1}\\E${2}$3/g"
      ).replace.should eql("- SOMEthing SELECTED")
    end
  end

  describe 'downcase' do
    it 'should apply downcase correctly' do
      RegexpHandler.new("SOMETHING SELECTED/^.+$/- \\l${0}/g").
        replace.should eql("- sOMETHING SELECTED")
    end

    it 'should apply big downcase correctly' do
      RegexpHandler.new("SOMETHING SELECTED/^.+$/- \\L${0}/g").
        replace.should eql("- something selected")
    end

    it 'should stop correctly' do
      RegexpHandler.new(
        "SOMETHING SELECTED/^(SOME)(THING)(.*)$/- \\L${1}\\E${2}$3/g"
      ).replace.should eql("- someTHING SELECTED")
    end
  end

  describe 'multiple case folders' do
    it 'should have no problem with multiple \u in the text' do
      RegexpHandler.new(
        'something selected/^(something) (selected)$/\u$1 \u$2/g'
      ).replace.should eql('Something Selected')
    end

    it 'should have no problem with multiple \U in the text' do
      RegexpHandler.new(
        'something selected/^(something) (selected)$/\U$1\Es\U$2/g'
      ).replace.should eql('SOMETHINGsSELECTED')
    end
  end
end
