require "mechanize"
require "pry"

module Authenticate
  module_function

  # @param username[String] username you wish to login as
  # @param password[String] password the user wishes to use
  def call(username,password)
    agent = Mechanize.new

    # google splits its authentication into 3 parts
    base_url = "https://accounts.google.com"
    response = agent.get base_url

    # a page to fill in the email...
    form = response.forms.first
    form.fields.find{ |field| field.name == "Email" }.value = username
    response = form.submit

    # a page to fill in the password...
    form = response.forms.first
    form.fields.find { |field| field.name == "Passwd" }.value  = password
    response = form.submit

    # and the 2factor authentication...
    loop do
      puts "I need your 2factor pin: "
      pin = $stdin.gets.strip
      form = response.forms.first
      form.fields.find { |field| field.name == "Pin" }.value = pin
      response = form.submit
      break response if response.uri.to_s == "https://www.google.com/settings/general-light?pli=1&ref=/"
      puts "#{pin} was not correct try again"
    end
    agent
  end
end
