require_relative 'request_helper'

class GitHubApi
  
  def initialize
    @@request_helper = RequestHelper.new
    @@headers = {
      'Authorization' => 'Bearer ' + ENV['GITHUB_AUTH_TOKEN']
    }   
  end
  
  def get_issues(owner, repository)
    $page = 1;
    $issues = [];
    loop do
      response = @@request_helper.request('GET',
                                          ENV['GITHUB_BASE_URL'] + 'repos/%s/%s/issues' %[owner, repository],
                                          :headers => @@headers,
                                          :query => {'page' => $page.to_s})
      if response.any?;
        $issues += response
        $page += 1;
      else
        return $issues
      end
    end
  end

  def get_attachement_content(url)
    response = @@request_helper.request('GET', url, return_raw=true, :headers => @@headers)
    return response.body
  end

end