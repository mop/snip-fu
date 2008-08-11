require 'spec_helper'

describe String, 'helper snippets' do
  before(:each) do
    String.send(:include, GeditSnippetMatcher)
  end

  describe 'with a few end tags' do
    it 'should have the correct count' do
      "}}}".end_snippet_count.should eql(3)
    end
  end

  describe 'with one start-tag and one end-tag' do
    before(:each) do
      @string = "${3:some message}"
    end
    it 'should have a start tag-count of one' do
      @string.start_snippet_count.should eql(1)
    end
    
    it 'should have a end tag-count of one' do
      @string.end_snippet_count.should eql(1)
    end

    it 'should return the correct index for the end-snippet' do
      @string.nth_snippet_end_index(1).should eql(@string.index("}"))
    end
  end

  describe 'with multiple nested tags' do
    before(:each) do
      @string = "some ${1:complex snippet ${5:which is } nested }"
    end

    it 'should have the correct start-index count' do
      @string.start_snippet_count.should eql(2)
    end

    it 'should have the correct end-snippet-count' do
      @string.end_snippet_count.should eql(2)
    end

    it 'should find the correct nested element' do
      @string.nth_snippet_end_index(2).should eql(@string.length - 1)
    end
  end
end

describe String, 'with snippet matcher included' do
  before(:each) do
    String.send(:include, GeditSnippetMatcher)
  end

  it 'should find a simple snippet' do
    "some${1}snippet".scan_snippets.should eql(["${1}"])
  end

  it 'should find a complex snippet' do
    "some ${1:complex} snippet".scan_snippets.should eql(["${1:complex}"])
  end

  it 'should find multiple simple snippets' do
    "some${1} snippet, which has ${2} multiple small snippets".
      scan_snippets.should eql(["${1}", "${2}"])
  end

  it 'should multiple complex snippets' do
    "some ${1:complex} snippet ${2}".scan_snippets.should eql(
      ["${1:complex}", "${2}"]
    )
  end

  it 'should find nested snippets' do
    "some ${1:complex snippet ${5:which is } nested } will hopefully work".
      scan_snippets.should eql(["${1:complex snippet ${5:which is } nested }"])
  end

  it 'should find very complex nested snippets' do
    "some ${1:nest${5:is } ${6:nest} s} will hopefully work".
      scan_snippets.should eql(["${1:nest${5:is } ${6:nest} s}"])
  end

  it 'should find very complex nested without content' do
    "some ${1:${5}${6}} will hopefully work".
      scan_snippets.should eql(["${1:${5}${6}}"])
  end

  it 'should parse multiline snippets' do
    "some ${1:\n${5}${6}} will hopefully work".
      scan_snippets.should eql(["${1:\n${5}${6}}"])
  end
end

describe String, 'escaping' do
  before(:each) do
    String.send(:include, GeditSnippetMatcher)
    @string = "{ :key => 'val' \\}"
  end
  
  it 'should not have end-tags' do
    @string.end_snippet_count.should eql(0)
  end

  it 'should provide a correct snippet_index-function' do
    str = "${2:sdfasdf\\}}"
    str.snippet_index("}").should eql(str.length - 1)
  end

  it 'should provide a correct snippet_index-function 2' do
    str = "${2:sdfasdf\\}\\}}\\}"
    str.snippet_index("}").should eql(str.length - 3)
  end
end

describe String, 'bugfixes' do
  before(:each) do
    String.send(:include, GeditSnippetMatcher)
  end

  it 'should match send_mail' do
    str = "send_mail(${1:${2:Some}Mailer}, :${3:mailer_action}${5:, {
	:from =&gt; ${10:'${11:from@acme.com}'}, 
	:to =&gt; ${12:'${13:some@user.com}'},
	:subject =&gt; ${15:'${16:Email subject}'}
\\}${20:, { :${25:user} =&gt; ${26:@user} \\}}})".scan_snippets.should eql([
      "${1:${2:Some}Mailer}", "${3:mailer_action}", "${5:, {
        :from =&gt; ${10:'${11:from@acme.com}'}, 
        :to =&gt; ${12:'${13:some@user.com}'},
        :subject =&gt; ${15:'${16:Email subject}'}
      \\}${20:, { :${25:user} =&gt; ${26:@user} \\}}}"
    ])
  end
end
