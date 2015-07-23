require_relative 'request_helper'

class RedmineApi
  
  def initialize
    @@request_helper = RequestHelper.new
    @@key_param = {'key' => ENV['REDMINE_API_KEY']}
  end
    
  def get_projects()
    response = @@request_helper.request('GET',
                                        ENV['REDMINE_BASE_URL'] + 'projects.json',
                                        :query => @@key_param)
    return response['projects']
  end

  def get_issues(project_id=nil, subprojecdt_id=nil, tracker_id=nil)
    query = {
      'project_id' => project_id,
      'subproject_id' => subprojecdt_id,
      'tracker_id' => tracker_id
      }.delete_if { |key, value| value.to_s.strip == '' }
    response = @@request_helper.request('GET', ENV['REDMINE_BASE_URL'] + 'issues.json', :query => query.merge!(@@key_param))
    return response
  end

  def create_issue(project_id,
                   subject,
                   description,
                   status_id=nil,
                   priority_id=nil,
                   assigned_to_id=nil,
                   attachments=nil)
    body = {
      'project_id' => project_id,
      'subject' => subject,
      'description' => description,
      'status_id' => status_id,
      'priority_id' => priority_id,
      'assigned_to_id' => assigned_to_id
      }.delete_if { |key, value| value.to_s.strip == '' }
    response = @@request_helper.request('POST',
                                        ENV['REDMINE_BASE_URL'] + 'issues.json',
                                        :query => @@key_param,
                                        :body => {'issue' => body})
    return response
  end  
  
end
