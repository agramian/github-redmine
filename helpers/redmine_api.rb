require 'json'
require 'httparty'


class RedmineApi
  
  def initialize
    @@key_param = {'key' => ENV['REDMINE_KEY']}
  end
    
  def get_projects()
    request = HTTParty.get(ENV['REDMINE_BASE_URL'] + 'projects.json',
                           :query => {}.merge!(@@key_param))
    response = JSON.parse request.body;
    return response['projects']
  end

  def get_issues()
    request = HTTParty.get(ENV['REDMINE_BASE_URL'] + 'issues.json',
                         :query => {}.merge!(@@key_param))
    response = JSON.parse request.body;
    puts response
  end  
end
