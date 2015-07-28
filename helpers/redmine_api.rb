require_relative 'request_helper'

class RedmineApi
  
  def initialize
    @@request_helper = RequestHelper.new
    @@key_param = {'key' => ENV['REDMINE_API_KEY']}
  end
    
  def get_user(id)
    return @@request_helper.request('GET', ENV['REDMINE_BASE_URL'] + 'users/' + id.to_s + '.json', :query => @@key_param)
  end

  def get_users(name=nil)
    query = {
      'name' => name
      }.delete_if { |key, value| value.to_s.strip == '' }
    return @@request_helper.request('GET', ENV['REDMINE_BASE_URL'] + 'users.json', :query => query.merge!(@@key_param))
  end

  def get_statuses()
    return @@request_helper.request('GET', ENV['REDMINE_BASE_URL'] + 'issue_statuses.json', :query => @@key_param)
  end

  def get_trackers()
    return @@request_helper.request('GET', ENV['REDMINE_BASE_URL'] + 'trackers.json', :query => @@key_param)
  end

  def get_priorities()
    return @@request_helper.request('GET', ENV['REDMINE_BASE_URL'] + 'enumerations/issue_priorities.json', :query => @@key_param)
  end

  def get_categories(project_id)
    return @@request_helper.request('GET', ENV['REDMINE_BASE_URL'] + 'projects/' + project_id.to_s + '/issue_categories.json', :query => @@key_param)
  end

  def get_projects()
    response = @@request_helper.request('GET', ENV['REDMINE_BASE_URL'] + 'projects.json', :query => @@key_param)
    return response['projects']
  end

  def get_issues(project_id=nil, subproject_id=nil, tracker_id=nil)
    query = {
      'project_id' => project_id,
      'subproject_id' => subproject_id,
      'tracker_id' => tracker_id
      }.delete_if { |key, value| value.to_s.strip == '' }
    return @@request_helper.request('GET', ENV['REDMINE_BASE_URL'] + 'issues.json', :query => query.merge!(@@key_param))
  end

  def get_issue(id)
    query = {
      'id' => id,
      'include' => 'attachments,journals'
      }.delete_if { |key, value| value.to_s.strip == '' }
    return @@request_helper.request('GET', ENV['REDMINE_BASE_URL'] + 'issues/' + id.to_s + '.json', :query => query.merge!(@@key_param))
  end

  def upload_attachment(content)
    headers = {
      'Content-Type' => 'application/octet-stream'
    }
    return @@request_helper.request('POST',
                                    ENV['REDMINE_BASE_URL'] + 'uploads.json',
                                    :headers => headers,
                                    :query => @@key_param,
                                    :body => content)
  end

  def create_issue(project_id,
                   subject,
                   description,
                   **options)
    """
    # TODO
    # take passed in attachments and change to format required for RedmineApi
    # 'uploads': [
      {'token': '7167.ed1ccdb093229ca1bd0b043618d88743', 'filename': 'image1.png', 'content_type': 'image/png'},
      {'token': '7168.d595398bbb104ed3bba0eed666785cc6', 'filename': 'image2.png', 'content_type': 'image/png'}
    ]
    if options[:attachments]
      uploads
    end
    """
    body = {
      'project_id' => project_id,
      'subject' => subject,
      'description' => description,
      'status_id' => options[:status_id] || nil,
      'priority_id' => options[:priority_id] || nil,
      'tracker_id' => options[:tracker_id] || nil,
      'assigned_to_id' => options[:assigned_to_id] || nil
      }.delete_if { |key, value| value.to_s.strip == '' }
    return @@request_helper.request('POST',
                                    ENV['REDMINE_BASE_URL'] + 'issues.json',
                                    :query => @@key_param,
                                    :body => {'issue' => body})
  end

  def update_issue(id,
                   subject,
                   description,
                   **options)
    body = {
      'subject' => subject,
      'description' => description,
      'project_id' => options[:project_id] || nil,
      'status_id' => options[:status_id] || nil,
      'priority_id' => options[:priority_id] || nil,
      'tracker_id' => options[:tracker_id] || nil,
      'assigned_to_id' => options[:assigned_to_id] || nil,
      'notes' => options[:notes] || nil
      }.delete_if { |key, value| value.to_s.strip == '' }
    return @@request_helper.request('PUT',
                                    ENV['REDMINE_BASE_URL'] + 'issues/' + id.to_s + '.json',
                                    return_raw=true,
                                    :query => @@key_param,
                                    :body => {'issue' => body})
  end

  def delete_issue(id)
    return @@request_helper.request('DELETE',
                                    ENV['REDMINE_BASE_URL'] + 'issues/' + id.to_s + '.json',
                                    return_raw=true,
                                    :query => @@key_param)
  end
  
end
