FactoryGirl.define do
  sequence(:redmine_id) { |n| n }
  sequence(:github_id) { |n| n }
  factory :issue do
    redmine_id
    github_id
  end              
end
