require 'rubygems'
require 'spec'
$:.unshift(File.dirname(__FILE__) + '/../src')

Dir[File.dirname(__FILE__) + '/../src/**/*.rb'].each do |file|
  require file unless file =~ /vim-snippet/
end

Dir[File.dirname(__FILE__) + '/mocks/**/*.rb'].each do |file|
  require file 
end
