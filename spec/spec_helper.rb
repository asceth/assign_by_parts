require "rubygems"
require "bundler"
Bundler.setup

require "rspec"
require "assign_by_parts"

Rspec.configure do |config|
  config.mock_with :rr
end
