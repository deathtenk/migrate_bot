require_relative "lib/authenticate.rb"
require_relative "lib/find_source_reports.rb"
require_relative "lib/report_discrepancies.rb"

# 458
task :find_discrepancies, [:user_id] do |t,args|
  client = Authenticate.call(ENV["STAQ_USERNAME"],ENV["STAQ_PASSWORD"])
  source_reports = FindSourceReports.call(client,args[:user_id])
  ReportDiscrepancies.call(client,source_reports)
end

task :find_discrepancies_for_id, [:user_id,:id] do |t,args|
  client = Authenticate.call(ENV["STAQ_USERNAME"],ENV["STAQ_PASSWORD"])
  source_reports = FindSourceReports.call(client,args[:user_id])
  ReportDiscrepancies.call(client,source_reports,args[:id])
end
