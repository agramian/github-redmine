require 'json'
require 'httparty'

class GitHubApi
  
  #puts response.body
  #puts response.code
  #response.message
  #response.headers.inspect
  
  def initialize
    @@headers = {
      'Authorization'=> 'Bearer ' + ENV['GITHUB_AUTH_TOKEN']
    }   
  end
  
  def get_issues(owner, repository)
    $page = 1;
    $issues = [];
    loop do
      request = HTTParty.get(ENV['GITHUB_BASE_URL'] + 'repos/%s/%s/issues' %[owner, repository],
                             :headers => @@headers,
                             :query => {'page' => $page.to_s})
      response = JSON.parse request.body;
      if response.any?;
        $issues += response
        $page += 1;
      else
        return $issues
      end
    end
  end
end