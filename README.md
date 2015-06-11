# Project name

# Description
A simple template for our sinatra projects.

# Link to app

# Tests

# Install
Before all, you must install gems: $ bundle install (or $ bundle update) when you want to run the app in **local machine**. Run browser and go to http://localhost/4567. [More options](#user-content-run). You can edit the port server in the Rakefile or controller file.

If you prefer use the app immediately, go [here](#user-content-link-to-app).

# Run
To see all option tasks: $ rake -T
```
rake 		  # Run the server via Sinatra (default task)
rake r        # Run the server via rackup
rake s        # Run the server via Sinatra
rake sinatra  # Run the server via Sinatra
rake spec     # Run rspec tests
rake tests    # Run tests
```

#Structure

- app: include:

 -- controllers: app controller functions

 -- helpers: support functions

 -- models: database and data structure

 -- views: web documents and templates

 -- tests: app testing and spec test

- routes and filters configuration
- public: css, js and other resources (media, etc)
- git files ignore
- Gemfile: gems specification
- Procfile: configuration file to heroku (PAAS)
- Rakefile: tasks and command list to run the app
- config.ru: rackup server configuration


# Resources

* [Sinatra](http://www.sinatrarb.com/)
* [Sinatra Gem](http://www.rubydoc.info/gems/sinatra)
* [Ruby Gems](https://rubygems.org/)
* [Bootstrap](http://getbootstrap.com/)

# Credits
