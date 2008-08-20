dir = File.dirname(__FILE__)
Dir["#{dir}/shared_behaviours/**/*.rb"].each do |file|
	require file
end
