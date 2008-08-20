dir = File.dirname(__FILE__)
Dir["#{dir}/mocks/**/*.rb"].each do |file|
	require file
end
