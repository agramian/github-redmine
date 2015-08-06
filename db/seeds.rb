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
  ['g3qa', 'Guidebook', 50, 'Guidebook Builder'],
  ['github-redmine-issues-test', 'abtin', 53, 'GitHub Redmine Integration Test']
]
projects.each do |github_repo_name, github_repo_owner, redmine_project_id, redmine_project_name|
  Project.create(github_repo_name: github_repo_name,
                 github_repo_owner: github_repo_owner,
                 redmine_project_id: redmine_project_id,
                 redmine_project_name: redmine_project_name)
end
# STATUSES
# arranged by precedence for situations where
# multiple labels are attached, the first match is used
statuses = [
  ['wontfix',       21, "Rejected (won't fix)"],
  ['invalid',       6,  'Rejected (invalid)'],
  ['duplicate',     20, 'Rejected (duplicate)'],
  ['Verified',      26, 'Verified'],
  ['Ready for QA',  24, 'Ready for QA'],
  ['In QA',         25, 'In QA'],
  ['In Progress',   2,  'In Progress'],
  ['open',          22, 'To Do'],
  ['closed',        23,  'Done']
]
statuses.each do |github_status_name, redmine_status_id, redmine_status_name|
  Status.create(github_status_name: github_status_name,
                redmine_status_id: redmine_status_id,
                redmine_status_name: redmine_status_name)
end
# ISSUE TYPES
issue_types = [
  ['bug',         21, 'Issue'],
  ['enhancement', 21, 'Issue'],
  ['Question/Help wanted',    22, 'Question/Help wanted']
]
issue_types.each do |github_issue_type_name, redmine_tracker_id, redmine_tracker_name|
  IssueType.create(github_issue_type_name: github_issue_type_name,
                   redmine_tracker_id: redmine_tracker_id,
                   redmine_tracker_name: redmine_tracker_name)
end
puts 'Successfully loaded seed data!'
