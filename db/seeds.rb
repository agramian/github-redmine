# PRIORITIES
priorities = [
  ['1 - Mild',     3,  'Trivial'],
  ['2 - Spicy',    4,  'Minor'],
  ['3 - Hot',      5,  'Major'],
  ['4 - Volcanic', 7,  'Critical'],
  ['5 - Suicidal', 11, 'Blocker']
]
priorities.each do |github_priority_name, redmine_priority_id, redmine_priority_name|
  Priority.create(github_priority_name: github_priority_name,
                  redmine_priority_id: redmine_priority_id,
                  redmine_priority_name: redmine_priority_name)
end
# PROJECTS
projects = [
  ['github-redmine-issues-test', 'abtin', 50, 'Guidebook Builder'],
]
projects.each do |github_repo_name, github_repo_owner, redmine_project_id, redmine_project_name|
  Project.create(github_repo_name: github_repo_name,
                 github_repo_owner: github_repo_owner,
                 redmine_project_id: redmine_project_id,
                 redmine_project_name: redmine_project_name)
end
# STATUSES
statuses = [
  ['open',              1,  'New'],
  ['In Progress',       2,  'In Progress'],
  ['closed',            5,  'Closed'],
  ['On Hold',           18, 'Deferred'],
  ['Ready for Review',  3,  'Resolved'],
  ['Fixed',             3,  'Resolved'],
  ['0 - wontfix',       6,  'Rejected'],
  ['invalid',           6,  'Rejected'],
  ['duplicate',         6,  'Rejected']
]
statuses.each do |github_status_name, redmine_status_id, redmine_status_name|
  Status.create(github_status_name: github_status_name,
                redmine_status_id: redmine_status_id,
                redmine_status_name: redmine_status_name)
end
# ISSUE TYPES
issue_types = [
  ['bug',         1, 'Bug'],
  ['enhancement', 2, 'Feature'],
  ['question',    4, 'Task'],
  ['help wanted', 4, 'Task'],
]
issue_types.each do |github_issue_type_name, redmine_tracker_id, redmine_tracker_name|
  IssueType.create(github_issue_type_name: github_issue_type_name,
                   redmine_tracker_id: redmine_tracker_id,
                   redmine_tracker_name: redmine_tracker_name)
end
puts 'Successfully loaded seed data!'
