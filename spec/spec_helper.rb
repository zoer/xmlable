$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'rubygems'
require 'bundler/setup'
require "xmlable"
require 'rspec'
require 'byebug'

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.order = :random

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.mock_with(:rspec) { |mocks| mocks.verify_partial_doubles = true }
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.include FixturesHelper
end
