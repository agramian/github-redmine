#The environment variable DATABASE_URL should be in the following format:
# => postgres://{user}:{password}@{host}:{port}/path
configure do
  postfix = ''
  if settings.test?
    postfix = '_TEST'
  elsif settings.development?
    postfix = '_DEV'
  else
    postfix = '_PROD'
  end
  db_username = ENV['DATABASE_USERNAME' + postfix]
  db_password = ENV['DATABASE_PASSWORD' + postfix]
  db_host = ENV['DATABASE_HOST' + postfix]
  db_name = ENV['DATABASE_NAME' + postfix]
	db = URI.parse("postgres://#{db_username}:#{db_password}@#{db_host}/#{db_name}")
	ActiveRecord::Base.establish_connection(
			:adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
			:host     => db.host,
			:username => db.user,
			:password => db.password,
			:database => db.path[1..-1],
			:encoding => 'utf8'
	)
end
