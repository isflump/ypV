require 'rufus-scheduler'
require 'soap/rpc/driver'
require 'soap/wsdlDriver'

def refresh_spira_object

  if ActiveRecord::Base.connection.table_exists? 'projects'
    projects = Project.all()
    driver = SOAP::WSDLDriverFactory.new("http://spirateam.ypg.com/Services/v4_0/ImportExport.svc?wsdl").create_rpc_driver
    response =  driver.Connection_Authenticate({userName: YpV::Application::SPIRA_USER_NAME, password: YpV::Application::SPIRA_PASSWORD})

    for p in projects
      driver.Connection_ConnectToProject({projectId: p.spira_id}).connection_ConnectToProjectResult
      testCaseNo = driver.TestCase_Count({}).testCase_CountResult.to_i
      if p.name == 'SFDC'
        isInclude=false
        for i in 1..((testCaseNo / 250).to_i + 1)
          i == 1 ? startPos =  1 : startPos = (i - 1) * 250
          driver.TestCase_Retrieve({startingRow: startPos,numberOfRows: 250}).testCase_RetrieveResult.remoteTestCase.each_with_index{|tc,i|
            isInclude=true if tc.name == "_Sales Force"
            isInclude=false if tc.name == "Z_TO_DELETE"
            if isInclude
              if YpV::Application::SPIRA_TC_NAME_MAP.has_key?(p.name)
                YpV::Application::SPIRA_TC_NAME_MAP[p.name][tc.name.strip]=tc
              else
                YpV::Application::SPIRA_TC_NAME_MAP[p.name]={tc.name.strip => tc}
              end
            end
          }
        end
      else
        for i in 1..((testCaseNo / 225).to_i + 1)
          i == 1 ? startPos =  1 : startPos = (i - 1) * 225
          driver.TestCase_Retrieve({startingRow: startPos,numberOfRows: 225}).testCase_RetrieveResult.remoteTestCase.each_with_index{|tc,i|
            if YpV::Application::SPIRA_TC_NAME_MAP.has_key?(p.name)
              YpV::Application::SPIRA_TC_NAME_MAP[p.name][tc.name.strip]=tc
            else
              YpV::Application::SPIRA_TC_NAME_MAP[p.name]={tc.name.strip => tc}
            end
          }
        end
      end
    end
  end
end

scheduler = Rufus::Scheduler.new
puts "Initializing Spira Case at #{Time.now}"
puts "This operation might take few miniutes before Ypv is fully started."
refresh_spira_object()


#runs only on sunday at 23
scheduler.cron '00 23 * * 0' do
  puts "Refresh Spira Cases at #{Time.now}"
  refresh_spira_object()
end
