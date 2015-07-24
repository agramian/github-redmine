ENV['RACK_ENV'] = 'test'
require 'dotenv'
Dotenv.load
require_relative '../app'
require 'minitest/autorun'
require 'rack/test'
require 'database_cleaner'
require 'factory_girl'
require 'json'
Dir[File.dirname(__FILE__) + '/factories/*.rb'].each {|file| require file }


DatabaseCleaner.strategy = :truncation

class WebhookTest < Minitest::Test
  include Rack::Test::Methods

  def setup
    DatabaseCleaner.start
    @issue = FactoryGirl.create(:issue)
    @redmine_events = {}
    @github_events = {}
    Dir[File.dirname(__FILE__) + '/json_data/redmine/*' ].each {|file|
      File.open(file, 'rb') { |f|
        @redmine_events[File.basename(file, File.extname(file))] = f.read
      }
    }
    Dir[File.dirname(__FILE__) + '/json_data/github/*'].each {|file|
      File.open(file, 'rb') { |f|
        @github_events[File.basename(file, File.extname(file))] = f.read
      }
    }
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
