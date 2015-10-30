# O Say Can You See: Early Washington, D.C., Law and Family Project

New repo for the OSCYS project, for the rails site.

### Run Locally

```
git clone git@github.com:CDRH/earlywashingtondc.git
bundle install
```

Copy `config/config.demo.yml` to `config/config.yml` and update it to reflect the correct solr, rdf, and owl urls.  You will need to create files in the same way at `config/database.yml` and `config/secrets.yml` if they do not exist.

```
rails s
```

Now you should be able to use a web browser to open `localhost:3000` to view the project.

### Run Tests

`rake test` will run all of the tests.  To run a single type of test, use a variation on the following:

```
rake test:helpers
rake test:controllers
rake test test/helpers/application_helper_test.rb
```

To run a specific test, change any spaces to underscores in its name:

```
rake test test/helpers/application_helper_test.rb _add_paginator_options
```

### Run Production

Set up everything as though you were setting it up to run locally (bundle install your gems, etc).  You'll need to determine how you will be serving the site.  We are using apache + phusion passenger.

To serve the assets with apache you will need to precompile them (at least, it seems that way).

```
RAILS_ENV=production bundle exec rake assets:precompile
```

You can also serve them from rails if you start altering things in the production.rb file to look more like development.rb.  Google for more information.

### Troubleshooting

There are several aspects to the OSCYS project hosted by UNL.  There is the Rails portion running with Phusion Passenger and Apache.  rvm is handling the gems.  There is a solr index (currently in tomcat) and there is a fuseki server running the RDF.  If there are problems out of the blue, check that both solr and fuseki's services are running.  If there are problems after a new commit, `touch tmp/restart.txt` in the rails project and wait a few seconds to see if Phusion Passenger just needs to restart to see the changes in production.  You may also want to make sure your assets are precompiled and that `bundle install` has been run for any new gems.
