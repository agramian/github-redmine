require 'sinatra'
require 'httparty'
require 'sinatra/activerecord'
Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file}
Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each {|file| require file}

# initialize classes
github_api = GitHubApi.new
redmine_api = RedmineApi.new
redmine_helper = RedmineHelper.new

get '/' do
	content_type :json
	Issue.order("ID DESC").all.to_json
end

post '/redmine_hook' do
	data = JSON.parse(request.body.read)['payload']
  project = Project.where(:redmine_project_id => data['issue']['project']['id']).first
	issue = Issue.where(redmine_id: data['issue']['id']).first
	if issue.present?
		# update on GitHub
    puts 'update'
	else
    # create on GitHub if non new state
    puts 'create'
	end
	'OK'
end

post '/github_hook' do
	data = JSON.parse(request.body.read)
	project = Project.where(:github_repo_name => data['repository']['name'],
                          :github_repo_owner => data['repository']['owner']['login']).first
  case data['action']
  when 'created'
    # process new comments
    redmine_helper.process_comment(data['comment'], data['issue']['number'], project)
  else
    # process issues
    redmine_helper.process_issue(data['issue'], project)
  end
	'OK'
end

after do
  # Close the connection after the request is done so that we don't
  # deplete the ActiveRecord connection pool.
  ActiveRecord::Base.connection.close
end
