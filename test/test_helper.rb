ENV['RACK_ENV'] = 'test'
require 'dotenv'
Dotenv.load
require_relative '../app'
require 'minitest/autorun'
require 'rack/test'
require 'database_cleaner'
require 'factory_girl'
require 'json'
Dir[File.dirname(__FILE__) + '/factories/*.rb'].each {|file| require file}

DatabaseCleaner.strategy = :truncation

class WebhookTest < Minitest::Test
  include Rack::Test::Methods

  def setup
    # reset database
    DatabaseCleaner.start
    # get project id
    redmine_api = RedmineApi.new
    redmine_projects = redmine_api.get_projects()
    @redmine_project = nil
    redmine_projects.each do |p|
      if p['name'] == ENV['REDMINE_TEST_PROJECT']
        @redmine_project = p
        break
      end
    end
    if !@redmine_project
      raise Exception, 'Unabled to find Redmine project "%s"' %[ENV['REDMINE_TEST_PROJECT']]
    end
    # create the test project in the db
    Project.create(:github_repo_name => ENV['GITHUB_TEST_REPO_NAME'],
                   :github_repo_owner => ENV['GITHUB_TEST_REPO_OWNER'],
                   :redmine_project_id => @redmine_project['id'],
                   :redmine_project_name => ENV['REDMINE_TEST_PROJECT'])
    # import json data to hash
    @redmine_events = {}
    @github_events = {}
    Dir[File.dirname(__FILE__) + '/data/json/redmine/*' ].each {|file|
      File.open(file, 'rb') { |f|
        data = JSON.parse(f.read)
        data['payload']['issue']['project']['id'] = @redmine_project['id']
        data['payload']['issue']['project']['name'] = ENV['REDMINE_TEST_PROJECT']
        data['payload']['issue']['author']['login'] = ENV['DEFAULT_AUTHOR']
        assignee = data['payload']['issue']['assignee']
        unless assignee.nil?
          data['payload']['issue']['assignee']['login'] = ENV['DEFAULT_ASSIGNEE']
        end
        @redmine_events[File.basename(file, File.extname(file))] = data.to_json
      }
    }
    Dir[File.dirname(__FILE__) + '/data/json/github/*'].each {|file|
      File.open(file, 'rb') { |f|
        data = JSON.parse(f.read)
        data['repository']['name'] = ENV['GITHUB_TEST_REPO_NAME']
        data['repository']['owner']['login'] = ENV['GITHUB_TEST_REPO_OWNER']
        data['issue']['user']['login'] = ENV['DEFAULT_AUTHOR']
        assignee = data['issue']['assignee']
        unless assignee.nil?
          data['issue']['assignee']['login'] = ENV['DEFAULT_ASSIGNEE']
        end
        @github_events[File.basename(file, File.extname(file))] = data.to_json
      }
    }
    # delete all redmine issues for the test project
    system('ruby', File.dirname(__FILE__) + '/../tasks/delete_all_redmine_issues.rb', '-p' , @redmine_project['name'])
    #
    system('ruby', File.dirname(__FILE__) + '/../db/seeds.rb')
    super
  end

  def teardown
    DatabaseCleaner.clean
    super
  end

  def app
    Sinatra::Application
  end
end
