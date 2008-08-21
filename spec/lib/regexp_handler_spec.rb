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

  describe 'conditionals' do
    it 'should handle a simple conditional' do
      RegexpHandler.new(
        'something selected/(something.*|other)/(?1:foo $1:bar)/g'
      ).replace.should eql('foo something selected')
    end

    it 'should handle a simple else conditional' do
      RegexpHandler.new(
        'something selected/something.*(nomatch)?/(?1:foo $1:bar)/g'
      ).replace.should eql('bar')
    end

    it 'should handle nested conditionals' do
      RegexpHandler.new(
        'something selected/(something).*(selected)/(?1:(?2:replaced))/g'
      ).replace.should eql('replaced')
    end
  end

  describe 'options' do
    it 'should forward regexp-options correctly' do
      regexp = Oniguruma::ORegexp.new('something', 'imxo')
      Oniguruma::ORegexp.should_receive(:new).with('something', 'imxo').
        and_return(regexp)
      RegexpHandler.new(
        'something selected/something/something/imxo'
      ).replace 
    end

    it 'should not screw up with no options given' do
      regexp = Oniguruma::ORegexp.new('something')
      Oniguruma::ORegexp.should_receive(:new).with('something', '').
        and_return(regexp)
      RegexpHandler.new(
        'something selected/something/something/'
      ).replace
    end

    it 'should not pass "g" to the options-string' do
      regexp = Oniguruma::ORegexp.new('something')
      Oniguruma::ORegexp.should_receive(:new).with('something', '').
        and_return(regexp)
      RegexpHandler.new(
        'something selected/something/something/g'
      ).replace
    end

    it 'should use gsub when selecting g as option' do
      regexp = mock('regexp')
      regexp.should_receive(:gsub).with('something selected', 'something').
        and_return("")
      Oniguruma::ORegexp.stub!(:new).and_return(regexp)
      RegexpHandler.new(
        'something selected/something/something/g'
      ).replace
    end

    it 'should use sub when not selecting g as option' do
      regexp = mock('regexp')
      regexp.should_receive(:sub).with('something selected', 'something').
        and_return("")
      Oniguruma::ORegexp.stub!(:new).and_return(regexp)
      RegexpHandler.new(
        'something selected/something/something/'
      ).replace
    end
  end
end
