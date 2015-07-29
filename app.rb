require 'sinatra'
require 'httparty'
require 'sinatra/activerecord'
Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file}
Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each {|file| require file}

get '/' do
	content_type :json
	Issue.order("ID DESC").all.to_json
end

post '/redmine_hook' do
	data = JSON.parse(request.body.read)
	issue = Issue.where(redmine_id: redmine.id).first
	if issue.present?
		# update
	else
		# create if non new state
	end
	'OK'
end

post '/github_hook' do
	data = JSON.parse(request.body.read)
	issue = Issue.where(github_id: github.id).first
	## Issue already created on Redmine
	if issue.present?
		# update
  else
    # create
	end
	'OK'
end

after do
  # Close the connection after the request is done so that we don't
  # deplete the ActiveRecord connection pool.
  ActiveRecord::Base.connection.close
end
