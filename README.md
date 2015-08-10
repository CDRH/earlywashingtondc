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