ENV['RACK_ENV'] = 'test'
require 'dotenv'
Dotenv.load
require_relative '../app'
require 'minitest/autorun'
require 'rack/test'
require "database_cleaner"
require 'factory_girl'
Dir[File.dirname(__FILE__)+"/factories/*.rb"].each {|file| require file }


DatabaseCleaner.strategy = :truncation

class FunctionalTest < Minitest::Test
  include Rack::Test::Methods

  def setup
    DatabaseCleaner.start
    @issue = FactoryGirl.create(:issue)
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
