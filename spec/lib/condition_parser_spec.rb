require File.dirname(__FILE__) + '/../spec_helper'
describe 'a condition parser' do
  describe 'with a simple condition' do
    it 'should parse simple then-conditions' do
      ConditionParser.new("(?val:true)").evaluate.should eql('true')
    end

    it 'should return nothing if nothing is in the if-part' do
      ConditionParser.new("(?:true)").evaluate.should eql('')
    end
  end

  describe 'with a simple else-clause' do
    it 'should return the then-part if the if-part is given'
    it 'should return the else-part if the else-part is given'
  end
  
  describe 'with strings before and after the parser' do
    it 'should let text before the condition alone' do
      ConditionParser.new('text(?something:true)').evaluate.should eql(
        'texttrue'
      )
    end

    it 'should let text after the condition alone' do
      ConditionParser.new('(?something:true)after').evaluate.should eql(
        'trueafter'
      )
    end

    it 'should allow text before and after the conditional' do
      ConditionParser.new('before(?something:true)after').evaluate.should eql(
        'beforetrueafter'
      )
    end
  end

  describe 'with multiple conditions in a row' do
    it 'should parse them correctly' do
      ConditionParser.new(
        'before(?something:true:false)after(?:true2:false2)'
      ).evaluate.should eql('beforetrueafterfalse2')
    end
  end

  describe 'with nested conditions' do
    it 'should parse them correctly' do
      ConditionParser.new(
        'before (?text:(?:then:(?:something:other)):else) after'
      ).evaluate.should eql('before other after')
    end
  end

  describe 'escaping of colons' do
    it 'should allow to escape colons using backslash' do
      ConditionParser.new(
        'before (?text:some\:thing:other)'
      ).evaluate.should eql('before some:thing')
    end
  end
end
