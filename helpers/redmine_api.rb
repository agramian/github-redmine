require_relative 'request_helper'

class RedmineApi
  
  def initialize
    @@request_helper = RequestHelper.new
    @@key_param = {'key' => ENV['REDMINE_API_KEY']}
  end
    
  def get_users(name=nil)
    query = {
      'name' => name
      }.delete_if { |key, value| value.to_s.strip == '' }
    response = @@request_helper.request('GET', ENV['REDMINE_BASE_URL'] + 'users.json', :query => query.merge!(@@key_param))
    return response
  end

  def get_projects()
    response = @@request_helper.request('GET',
                                        ENV['REDMINE_BASE_URL'] + 'projects.json',
                                        :query => @@key_param)
    return response['projects']
  end

  def get_issues(project_id=nil, subproject_id=nil, tracker_id=nil)
    query = {
      'project_id' => project_id,
      'subproject_id' => subproject_id,
      'tracker_id' => tracker_id
      }.delete_if { |key, value| value.to_s.strip == '' }
    response = @@request_helper.request('GET', ENV['REDMINE_BASE_URL'] + 'issues.json', :query => query.merge!(@@key_param))
    return response
  end

  def get_issue(id)
    query = {
      'id' => id,
      'include' => 'attachments,journals'
      }.delete_if { |key, value| value.to_s.strip == '' }
    response = @@request_helper.request('GET', ENV['REDMINE_BASE_URL'] + 'issues/' + id.to_s + '.json', :query => query.merge!(@@key_param))
    return response
  end

=begin
  def upload_attachment()
    headers = {
      'Content-Type' => 'application/octet-stream'
    }
    query = {
      'id' => id,
      'include' => 'attachments,journals'
      }.delete_if { |key, value| value.to_s.strip == '' }
    response = @@request_helper.request('GET',
                                        ENV['REDMINE_BASE_URL'] + 'uploads.json',
                                        :headers => headers,
                                        :query => query.merge!(@@key_param))
    return response
  end
=end

  def create_issue(project_id,
                   subject,
                   description,
                   **options)
    body = {
      'project_id' => project_id,
      'subject' => subject,
      'description' => description,
      'status_id' => options[:status_id] || nil,
      'priority_id' => options[:priority_id] || nil,
      'assigned_to_id' => options[:assigned_to_id] || nil
      }.delete_if { |key, value| value.to_s.strip == '' }
    response = @@request_helper.request('POST',
                                        ENV['REDMINE_BASE_URL'] + 'issues.json',
                                        :query => @@key_param,
                                        :body => {'issue' => body})
    return response
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
      'assigned_to_id' => options[:assigned_to_id] || nil,
      'notes' => options[:notes] || nil
      }.delete_if { |key, value| value.to_s.strip == '' }
    response = @@request_helper.request('PUT',
                                        ENV['REDMINE_BASE_URL'] + 'issues/' + id.to_s + '.json',
                                        return_raw=true,
                                        :query => @@key_param,
                                        :body => {'issue' => body})
    return response
  end

  def delete_issue(id)
    response = @@request_helper.request('DELETE',
                                        ENV['REDMINE_BASE_URL'] + 'issues/' + id.to_s + '.json',
                                        return_raw=true,
                                        :query => @@key_param)
    return response
  end
  
end
