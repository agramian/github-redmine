require_relative 'request_helper'

class GitHubApi
  
  def initialize
    @@request_helper = RequestHelper.new
    @@headers = {
      'Authorization' => 'Bearer ' + ENV['GITHUB_AUTH_TOKEN']
    }   
  end
  
  def get_issue(owner, repository, number)
    return @@request_helper.request('GET',
                                    ENV['GITHUB_BASE_URL'] + 'repos/%s/%s/issues/%s' %[owner, repository, number.to_s],
                                    :headers => @@headers)
  end

  def get_issues(owner, repository, state='all')
    $page = 1;
    $issues = [];
    loop do
      response = @@request_helper.request('GET',
                                          ENV['GITHUB_BASE_URL'] + 'repos/%s/%s/issues' %[owner, repository],
                                          :headers => @@headers,
                                          :query => {'page' => $page.to_s, 'state' => state})
      if response.any?;
        $issues += response
        $page += 1;
      else
        return $issues
      end
    end
  end

  def create_issue(owner,
                   repository,
                   title,
                   body,
                   **options)
    body = {
      'title' => title,
      'body' => body,
      'assignee' => options[:assignee] || nil,
      'milestone' => options[:milestone] || nil,
      'labels' => options[:labels] || nil
      }.delete_if { |key, value| value.to_s.strip == '' }
    return @@request_helper.request('POST',
                                    ENV['GITHUB_BASE_URL'] + 'repos/%s/%s/issues' %[owner, repository],
                                    :headers => @@headers,
                                    :body => body.to_json)
  end

  def edit_issue(owner, repository, number, **options)
    body = {
      'title' => options[:title] || nil,
      'body' => options[:body] || nil,
      'assignee' => options[:assignee] || nil,
      'milestone' => options[:milestone] || nil,
      'labels' => options[:labels] || nil
      }.delete_if { |key, value| value.to_s.strip == '' }
    return @@request_helper.request('PATCH',
                                    ENV['GITHUB_BASE_URL'] + 'repos/%s/%s/issues/%s' %[owner, repository, number.to_s],
                                    :headers => @@headers,
                                    :body => body.to_json)
  end

  def get_comment(owner, repository, id)
    return @@request_helper.request('GET',
                                    ENV['GITHUB_BASE_URL'] + 'repos/%s/%s/issues/comments/%s' %[owner, repository, id.to_s],
                                    :headers => @@headers)
  end

  def get_comments(owner, repository, issue_id)
    $page = 1;
    $comments = [];
    loop do
      response = @@request_helper.request('GET',
                                          ENV['GITHUB_BASE_URL'] + 'repos/%s/%s/issues/%s/comments' %[owner, repository, issue_id.to_s],
                                          :headers => @@headers,
                                          :query => {'page' => $page.to_s})
      if response.any?;
        $comments += response
        $page += 1;
      else
        return $comments
      end
    end
  end

  def create_comment(owner, repository, issue_number, body, attachments=nil)
    body = {'body' => body}
    return @@request_helper.request('POST',
                                    ENV['GITHUB_BASE_URL'] + 'repos/%s/%s/issues/%s/comments' %[owner, repository, issue_number.to_s],
                                    :headers => @@headers,
                                    :body => body.to_json)
  end

  def edit_comment(owner, repository, id, body, attachments=nil)
    body = {'body' => body}
    return @@request_helper.request('PATCH',
                                    ENV['GITHUB_BASE_URL'] + 'repos/%s/%s/issues/comments/%s' %[owner, repository, id.to_s],
                                    :headers => @@headers,
                                    :body => body.to_json)
  end

  def get_attachement_content(url)
    response = @@request_helper.request('GET', url, return_raw=true, :headers => @@headers)
    return response.body
  end

end
