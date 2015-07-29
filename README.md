GitHub Redmine Integration
==========================

Description
-----------
A web server which receives event updates from the GitHub and Redmine webhooks and then syncs/creates/updates issues between both system's appropriately.

Setup
-----
#### Redmine

###### Version Requirement
Redmine >= 2.4 is required to take advantage of the [REST API](http://www.redmine.org/projects/redmine/wiki/Rest_api)

###### Enable REST web service
1. Go to your redmine instance
2. Click the "Administration" link.
3. Click "Settings".
4. Go to the "Authentication" tab.
5. Make sure "Enable REST web service" is checked.

###### Webhook plugin
1. Install the [Redmine Webhook](https://github.com/suer/redmine_webhook) plugin.
2. Go to your Redmine instance.
3. Click the "Settings" tab.
4. Click the "WebHook" tab.
5. Modify the URL to point to the address and port of your server followed by "/redmine_hook" (ex: http://example.com:9494/redmine_hook)

###### Get your API access key
1. Go to your redmine instance
2. Click the "My account" link.
3. Create or show your "API access key" at the right.

#### GitHub

###### Configure Webhook
1. Go to the GitHub repository you want to use.
2. If you have the appropriate privileges, you will see a "Settings" link under the right column where other links such as "Code", "Issues", "Pull Requests", "Wiki", etc. are listed. Click on the "Settings" link.
3. Under the left "Options" column click on "Webhooks & Services".
4. From the "Webhooks" box click "Add webhook".
5. Under "Payload URL" enter the URL to point to the address and port of your server followed by "/github_hook" (ex: http://example.com:9494/github_hook)
6. Make sure "Content type" is set to "application/json".
7. Click "Let me select individual events" and select "Issues" and "Issue comment".

#### Environment variables
Create a `.env` file in the project root to define the necessary environment variables.
Example file below:
```
DATABASE_URL='postgres://localhost/mydb'
DATABASE_NAME='mydb'
DATABASE_USERNAME='postgres'
DATABASE_PASSWORD=''
DATABASE_HOST='localhost'

GITHUB_BASE_URL='https://github.example.com/api/v3/'
GITHUB_AUTH_TOKEN='xxxxxx'

REDMINE_BASE_URL='http://example.guidebook.com/'
REDMINE_API_KEY='xxxxx'

SLACK_BASE_URL='https://example.slack.com/api/'
SLACK_AUTH_TOKEN='xxxxx'

DEFAULT_ASSIGNEE='abtin'
DEFAULT_AUTHOR='abtin'
```

#### Field mapping
Modify the `db\seeds.rb` file to map Redmine and GitHub fields.

#### Installing dependencies

###### PostgreSQL
```
# install brew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# install postgres
brew install postgres
# start server
pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start
# stop server
pg_ctl -D /usr/local/var/postgres stop -s -m fast
````

###### Bundle and bootstrap
```
# for development
bundle
# for production
bundle install --without test development`
# create and migrate database
rake db:migrate:reset
# generate the schema and load the seed data
rake db:setup
```

###### (Optional) Delete all Redmine Issues
A rake task is provided to delete all existing issues from one or more Redmine projects.
The rake task takes a semicolon separated list of Redmine project names or 'ALL'.
```
rake delete_all_redmine_issues['ALL']
```

###### (Optional) Sync Redmine with GitHub
A rake task is provided to sync/create all GitHub issues with the associated Redmine project(s).
The rake task takes a semicolon separated list of Redmine project names or 'ALL'.
```
rake sync_redmine_to_github['PROJECT1;PROJECT2']
```

Running
-------

#### Test and Development
`rerun "rackup"` to start server.  
`rake test` to run all tests once.  
`bundle exec guard` to initiate file watch and run tests on every change.  

### Debugging
`racksh` to start console
Ex:
`$rack.get '/test-endpoint'`
`$rack.post "/users", :user => { :name => "Jola", :email => "jola@misi.ak" }`
`reload!` to restart console after changes
[More info](https://github.com/sickill/racksh)  

### Production
Run bundle and bootstrap commands from above with `RACK_ENV=production`.  
Run `RACK_ENV=production rackup`.  

Other
-----
In case API responses change in the future, to generate test JSON data from the webhooks place the following code block in the app.rb `post /github` and `post /redmine` methods.
Then create/update/close issues etc. from Redmine and GitHub and save the files appropriately.
```
File.open(File.join(File.dirname(__FILE__), 'test/json_responses/redmine_test.json'),"w") do |f|
  f.write(request.body.read)
end
```

### Technology

- Ruby 2.2
- Sinatra
- PostgreSQL

### Credit

Some inspiration borrowed from [issue-sync-redmine-github](https://github.com/gmontard/issue-sync-redmine-github).

