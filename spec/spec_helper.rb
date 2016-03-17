require "pry"

CWD = File.dirname(__FILE__)
SPEC_DATA_DIR = "#{CWD}/data"

RSpec.configure do |config|
  config.mock_with :rspec
end

VCR.configure do |c|
  c.cassette_library_dir = "#{SPEC_DATA_DIR}/vcr"
  c.default_cassette_options = {
    record: :once
  }
  c.filter_sensitive_data("<STAQ_USERNAME>") { CGI.escape(ENV["STAQ_USERNAME"]) }
  c.filter_sensitive_data("<STAQ_PASSWORD>") { CGI.escape(ENV["STAQ_PASSWORD"]) }
end
$:.unshift("#{CWD}/../lib")

