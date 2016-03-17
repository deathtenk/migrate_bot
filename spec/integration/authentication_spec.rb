require "authenticate"
require "vcr"
require_relative "../spec_helper.rb"

ENV["STAQ_USERNAME"] ||= "fake_username"
ENV["STAQ_PASSWORD"] ||= "fake_password"


RSpec.describe "authenticate as google user" do
  before do
    # hack to get the correct pin for the test
    pin = "fake_pin"
    $stdin = StringIO.new("#{pin}\n")
  end

  after do
    $stdin = STDIN
  end

  let(:username) do
    ENV["STAQ_USERNAME"]
  end

  let(:password) do
    ENV["STAQ_PASSWORD"]
  end

  skip "Should return an authenticated mechanize client" do
    VCR.use_cassette "authenticate", preserve_exact_body_bytes: true do
      client = Authenticate.call(username,password)
      expect(client.uri.to_s).to eq("https://www.google.com/settings/general-light?pli=1&ref=/")
    end
  end
end
