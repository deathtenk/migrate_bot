require "pry"
require "mechanize"
require "yajl"

module ReportDiscrepancies

  module_function
  def call(client,sources,source_id = nil)
    base_url = "https://app.staq.com"
    headers = {
      "Accept" => "application/json"
    }

    sources = sources.select {|source| source.fetch(:id) == source_id.to_i} if source_id

    sources.each do |source|
      source_id = source.fetch(:id)
      view_url = source.fetch(:view_url)

      response = client.get "#{base_url}#{view_url}"
      report_url = response.search("li.download").first.children[1].attributes.fetch("href").value[/(.+)\/export$/,1]
      params = {
        :"settings[totals_only]" => true,
        :"settings[filters][date][0][column]" => "date",
        :"settings[filters][date][0][columnType]" => "Date",
        :"settings[filters][date][0][logical_operator]" => "and",
        :"settings[filters][date][0][operator]" => "TimeRange",
        :"settings[filters][date][0][type]" => "inclusion",
        :"settings[filters][date][0][values][]" => "09/16/2015 to 03/11/2016",
        use_replica: false,
        :"_" => (Time.now.to_f * 1000).to_i
      }
      begin
        none_replica_response = client.get "#{base_url}#{report_url}",params,nil,headers
      rescue
        puts "no data exists for #{report_url}"
        next
      end 
      none_replica_data = Yajl::Parser.parse(none_replica_response.body, symbolize_keys: true).fetch(:totals)
      params = {
        :"settings[totals_only]" => true,
        :"settings[filters][date][0][column]" => "date",
        :"settings[filters][date][0][columnType]" => "Date",
        :"settings[filters][date][0][logical_operator]" => "and",
        :"settings[filters][date][0][operator]" => "TimeRange",
        :"settings[filters][date][0][type]" => "inclusion",
        :"settings[filters][date][0][values][]" => "09/16/2015 to 03/11/2016",
        use_replica: true,
        :"_" => (Time.now.to_f * 1000).to_i
      }
      replica_response = client.get "#{base_url}#{report_url}",params,nil,headers
      replica_data = Yajl::Parser.parse(replica_response.body, symbolize_keys: true).fetch(:totals)
      
      puts "checking difference between replica_data and none_replica_data for #{source_id}, found at #{view_url}"

      diff = replica_data - none_replica_data
      unless diff.empty?
        puts "found difference, writing #{source_id} difference to disk..."
        replica_json = { replica_data: replica_data,
                         none_replica_data: none_replica_data,
                         view_url: view_url }
        IO.write("#{Dir.pwd}/data/#{source_id}_differences.json",replica_json.to_json)
      else
        puts "no discrepancy found for #{source_id}"
      end
    end
  end
end
