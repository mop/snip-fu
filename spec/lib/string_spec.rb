require File.dirname(__FILE__) + '/../spec_helper'

describe String, 'start_tag-method' do
  before(:each) do
    String.send(:include, GeditSnippetMatcher)
  end

  it 'should extract the start-tag correctly on extended-snippets' do
    string = "${4:asdf}"
    string.start_tag.should eql("${4:")
  end

  it 'should extract the start-tag correctly on regular-snippets' do
    string = "${4}"
    string.start_tag.should eql("${4")
  end
end

describe String, 'digit_tag-method' do
  before(:each) do
    String.send(:include, GeditSnippetMatcher)
  end

  it 'should extract the digit out of extended tags' do
    "${23:something}".digit_tag.should eql('23')
  end

  it 'should extract the digit out of regular tags' do
    "${23}".digit_tag.should eql('23')
  end
  
end

describe String, 'tag?-method' do
  it 'should identify extended tags' do
    '${1:extended}'.should be_tag
  end

  it 'should identify regular tags' do
    '${1}'.should be_tag
  end

  it 'should return nil on translators' do
    '${1/some/thing/g}'.should_not be_tag
  end

  it 'should return nil on non-tags' do
    'no tag ${1}'.should_not be_tag
  end
end

describe String, 'without_tags-method' do
  before(:each) do
    String.send(:include, GeditSnippetMatcher)
  end

  it 'should remove the tags correctly' do
    string = "${4:asdf}"
    string.without_tags.should eql("asdf")
  end

  it 'should remove nested tags correctly' do
    string = "${4:asdf${2:zomg{}}}"
    string.without_tags.should eql("asdf${2:zomg{}}")
  end

  it 'should remove the empty tags correctly' do
    string = "${4}"
    string.without_tags.should eql("")
  end

  it 'should remove a very long string correctly' do
    string = "${5:, { 
        :from =&gt; ${10:'${11:from@acme.com}'},
        :to =&gt; ${12:'${13:some@user.com}'},
        :subject =&gt; ${15:'${16:Email subject}'}
}${20:, { :${25:user} =&gt; ${26:@user} }}}"
    string.without_tags.should eql(", { 
        :from =&gt; ${10:'${11:from@acme.com}'},
        :to =&gt; ${12:'${13:some@user.com}'},
        :subject =&gt; ${15:'${16:Email subject}'}
}${20:, { :${25:user} =&gt; ${26:@user} }}")
  end
end

describe String, 'single_tags?' do
  before(:each) do
    String.send(:include, GeditSnippetMatcher)
  end

  it 'should return true for single tags' do
    string = "${4}"
    string.single_tag?.should be_true
  end

  it 'should return false for extended tags' do
    string = "${4:something}"
    string.single_tag?.should be_false
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

  it 'should work with regular brackets under some circumstances' do
    "some ${1: { ${2: arg } ${3: arg } } }".scan_snippets.should eql([
      "${1: { ${2: arg } ${3: arg } } }"
    ])
  end

  it 'should work with regular brackets outside the expression' do
    "{some ${1: { ${2: arg } ${3: arg } } }}".scan_snippets.should eql([
      "${1: { ${2: arg } ${3: arg } } }"
    ])
  end

  it 'should return the correct positions to a stream' do
    "${1}".scan_snippets_positions.should eql([[0, 3]])
  end
end

describe String, 'bugfixes' do
  before(:each) do
    String.send(:include, GeditSnippetMatcher)
  end

  it 'should match aftp' do
    str = "after Proc.new { |c| ${1:c.some_method} }${2:, :${10:only} =&gt; ${11:[${12::login, :signup}]}}"
    str.scan_snippets.should eql([
      "${1:c.some_method}", 
      "${2:, :${10:only} =&gt; ${11:[${12::login, :signup}]}}"
    ])
  end

  it 'should match send_mail' do
    str = "send_mail(${1:${2:Some}Mailer}, :${3:mailer_action}${5:, {
	:from =&gt; ${10:'${11:from@acme.com}'}, 
	:to =&gt; ${12:'${13:some@user.com}'},
	:subject =&gt; ${15:'${16:Email subject}'}
}${20:, { :${25:user} =&gt; ${26:@user} }}})"
    str.scan_snippets.should eql([
      "${1:${2:Some}Mailer}",
      "${3:mailer_action}",
      "${5:, {
	:from =&gt; ${10:'${11:from@acme.com}'}, 
	:to =&gt; ${12:'${13:some@user.com}'},
	:subject =&gt; ${15:'${16:Email subject}'}
}${20:, { :${25:user} =&gt; ${26:@user} }}}"
    ])
  end

  it 'should match send_mail subexpr' do
    str = ", {
	:from =&gt; ${10:'${11:from@acme.com}'}, 
	:to =&gt; ${12:'${13:some@user.com}'},
	:subject =&gt; ${15:'${16:Email subject}'}
}${20:, { :${25:user} =&gt; ${26:@user} }})"
    str.scan_snippets.should eql([
      "${10:'${11:from@acme.com}'}",
      "${12:'${13:some@user.com}'}",
      "${15:'${16:Email subject}'}",
      "${20:, { :${25:user} =&gt; ${26:@user} }}"
    ])
  end
end
