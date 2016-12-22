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

Set up everything as though you were setting it up to run locally (bundle install your gems, etc).  Preferably, you will be using a Ruby version manager for this step to avoid conflicts with other Ruby projects.  You'll need to determine how you will be serving the site.  We are using apache + phusion passenger.

To serve the assets with apache you will need to precompile them (at least, it seems that way).

```
# use for earlywashingtondc.org and locally run production
RAILS_ENV=production bundle exec rake assets:precompile

# use this if you are running the project at a suburi (server.unl.edu/earlywashingtondc)
RAILS_RELATIVE_URL_ROOT="/earlywashingtondc" RAILS_ENV=production rake assets:precompile
```

You can also serve them from rails if you start altering things in the production.rb file to look more like development.rb, but this should be avoided if possible, because it's far more efficient to precompile and serve the assets with Apache.

If you are having trouble getting all the assets to show up, [refer to this document](https://docs.google.com/drawings/d/1sKa--VQmFamOephFNF6QOANYSFJXrOXALVwrmQL3RqU/edit?usp=sharing) to verify that your JS, CSS, images, 3rd-party libraries, etc are set up correctly.

### Design

There are several components to OSCYS.

#### Rails App

This is the repo you are currently looking at, it pulls together RDF, Solr responses, and HTML snippets to create the website

#### RDF via Fuseki

This component is being created from relationships between people. Scripts and files powering this are stored in the data_oscys folder, and a Fuseki server points at files for its queries. This creates information on people pages and provides information for the visualizations.

#### Solr

TEI files are converted and uploaded to Solr in the data_oscys project. The Rails app then sends queries to Solr to obtain search results, and listings for documents, cases, and people.

#### TEI -> HTML

On a case, document, or person page, some of the metadata is provided by Solr. For documents in particular, HTML snippets pregenerated from TEI XML files are pulled into the Rails application. These contain text, images, page breaks, and footnotes.

#### Phusion Passenger and Apache

The Rails application is being served through Phusion and Apache.

### Troubleshooting

#### Why are there errors on the people pages but not the documents, cases?

This probably indicates that there is a problem with the Fuseki server or one of the files it should be reading. Ask a sysadmin or developer to check that Fuseki is running.  If it is, then check that the ttl and owl files in the data_oscys project look okay, and roll back to a different version in git if necessary. If the problem persists, check that the Rails app environment you are running is correctly pointing at Fuseki, and that there are no firewalls or other obstacles blocking the connection. If you change the config file, `touch tmp/restart.txt` to restart the server.

#### I can't view documents, cases, people, or the search pages

This sounds like Solr may not be hooked up correctly. Verify that Solr is running, and then check that your environment is set to the correct endpoint. There's a small chance that you may need to reindex the documents, though if this were the case then the search pages should at least be working but showing nothing in the dropdowns or search results. You may also want to check that the Jetty port is open, firewalls, etc. If you change the config file, `touch tmp/restart.txt` to restart the applications.

#### The website is gone and there's just a Phusion Passenger error?

It could be that a gem was added to the app which hasn't been downloaded, yet.  `bundle install` to see if that fixes the problem.  No?

Well, in that case, let's check the Ruby version in `.ruby-version` against the Ruby and gem locations listed in the apache configuration. Make sure that these line up, then run `bundle install` just for good measure.

If there is some sort of a permissions error, it might be that the app lacks sufficient permissions to write to logs or temporary files. It may also be that SELinux or Apache mod-sec are preventing this from happening, so try checking those logs to see if there is any chatter about oscys in them.

#### Why is the styling gone?

It worked locally but not on the server, eh?  If the app is set to production mode, then you will need to verify that you have precompiled the assets and that they are being included correctly. See the above paragraph on asset compiling.
