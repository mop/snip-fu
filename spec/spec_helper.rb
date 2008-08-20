require 'rubygems'
require 'spec'
$:.unshift(File.dirname(__FILE__) + '/../src')

dir = File.dirname(__FILE__)
Dir["#{dir}/../src/**/*.rb"].each do |file|
  require file unless file =~ /vim-snippet/
end

require "#{dir}/spec_helpers/mocks"
require "#{dir}/spec_helpers/behaviours"
require "#{dir}/spec_helpers/shared_behaviours"

