require "pry"
require "yajl"

module FindSourceReports
  module_function

  # @param client[Mechanize] client needed to download the data
  # @param user_id[String] user you would like to disguise yourself as
  # hint: find a user who manages the account you need to check
  def call(client,user_id)
    base_url = "https://app.staq.com"
    response = client.get "#{base_url}/admin?identifier=#{user_id}"
    page = response.links.first.click

    page.forms.first.fields.find { |field| field.name == "identifier" }.value = user_id
    page.forms.first.submit

    response = client.get "#{base_url}/source_manager"
    source_manager_data = Yajl::Parser.parse(response.body[/StaqSourceManager\.BOOTSTRAPPED_JSON = (.+)\s\|\|/,1], symbolize_keys: true)
    custom_source_ids = source_manager_data.fetch(:custom_sources).map { |data| { id: data.fetch(:id), view_url: data.fetch(:view_url) } }
    
    connection_view_ids = source_manager_data.fetch(:connections).map do |connection|
      connection.fetch(:scopes).map do |scope|
        { id: scope.fetch(:id), view_url: scope.fetch(:view_url) }
      end
    end.flatten

    custom_source_ids.concat(connection_view_ids)
  end
end
