require 'dotenv'
Dotenv.load
require 'sinatra'
require 'httparty'
require 'sinatra/activerecord'
Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file}
Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each {|file| require file}

# initialize classes
github_api = GitHubApi.new
redmine_api = RedmineApi.new
redmine_helper = RedmineHelper.new
github_helper = GitHubHelper.new

get '/' do
	content_type :json
	Issue.order("ID DESC").all.to_json
end

post '/redmine_hook' do
  begin
  	data = JSON.parse(request.body.read)['payload']
    # create/edit on GitHub if non new state
    issue_state = Status.where(redmine_status_id: data['issue']['status']['id']).first.redmine_status_name
    if issue_state == 'New'
      puts 'Redmine issue with %s for the "%s" project is still in the "New" state and will not be created in GitHub' \
           %[data['issue']['id'], data['issue']['project']['name']]
      status 204
    else
      github_helper.process_issue(data['issue'])
    end
  	'OK'
  rescue => exception
    status 500
    exception = "Exception occured while processing github_hook!" \
                "\nBacktrace:\n\t#{exception.backtrace.join("\n\t")}" \
                "\nMessage: #{exception.message}"
    puts exception
    exception
  end
end

post '/github_hook' do
  begin
  	data = JSON.parse(request.body.read)
  	project = Project.where(:github_repo_name => data['repository']['name'],
                            :github_repo_owner => data['repository']['owner']['login']).first
    case data['action']
    when 'created'
      # process new comments
      redmine_helper.process_comment(data['comment'], data['issue']['number'], project)
      # hipchat message TODO
    else
      # process issues
      redmine_helper.process_issue(data['issue'], project)
      # hipchat message TODO
    end
  	'OK'
  rescue => exception
    status 500
    exception = "Exception occured while processing github_hook!" \
                "\nBacktrace:\n\t#{exception.backtrace.join("\n\t")}" \
                "\nMessage: #{exception.message}"
    puts exception
    exception
  end
end

after do
  # Close the connection after the request is done so that we don't
  # deplete the ActiveRecord connection pool.
  ActiveRecord::Base.connection.close
end
