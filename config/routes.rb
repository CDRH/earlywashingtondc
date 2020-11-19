with_period = /[^\/]+/
with_period_ext = /[^\/]+(?=(\.json)|(\.xml)|(\.html))+/

Rails.application.routes.draw do
  root 'static#index'

  # static pages
  get '/' => 'static#index', as: :home
  get 'interest' => 'static#interest', as: :interest
  get 'rdf/relationships.ttl' => redirect("http://earlywashingtondc.org/rdf/oscys.relationships.ttl"), :as => :rdf
  get 'rdf/ontology.owl' => redirect("http://earlywashingtondc.org/rdf/oscys.objectproperties.owl"), :as => :owl
  get 'rdf/relationships.csv' => redirect("http://earlywashingtondc.org/rdf/oscys.relationships.csv"), :as => :csv

  # external links with named routes
  get 'github' => redirect("https://github.com/CDRH/earlywashingtondc"), :as => :repo
  get 'contribute' => 'static#contribute', as: :contribute
  get 'faq' => 'static#faq', as: :faq
  get 'ead' => 'static#ead', as: :ead

  # documents (browsing / searching)
  post 'browse' => 'documents#dropdown', as: :doc_dropdown
  get 'doc/:id', to: 'documents#show', as: :doc, :constraints => { :id => with_period }
  get 'advancedsearch' => 'documents#advancedsearch', as: :advancedsearch
  match 'search', to: 'documents#search', as: :search, :constraints => { :id => with_period }, via: [:get, :post]

  # cases
  get 'cases' => 'cases#index', as: :cases
  match 'cases/annotated' => 'cases#annotated', as: :casesAnnotated, via: [:get, :post]
  match 'cases/all' => 'cases#all', as: :casesAll, via: [:get, :post]
  match 'cases/documents' => 'documents#index', as: :documents, via: [:get, :post]
  get 'cases/:id' => 'cases#show', as: :case, :constraints => { :id => with_period }

  # people
  # I don't want to talk about this.  Due to sucking at regex, I never figured out a way to
  # capture ONLY the id regardless of whether there was an extension (.json, etc) or not, so I wrote two routes.
  match 'people', to: 'people#index', as: :people, via: [:get, :post]
  match 'people/all', to: 'people#all', as: :peopleAll, via: [:get, :post]
  get 'people/network/:id', to: 'people#network', :constraints => { :id => with_period_ext}
  get 'people/network/:id', to: 'people#network', as: :network_vis, :constraints => { :id => with_period }
  post 'people/browse', to: 'people#browse', as: :person_browse, :constraints => { :id => with_period }
  get 'people/relationships', to: 'people#relationships', as: :relationships
  get 'people/connection_type', to: "people#connection_type", as: :connection_type # doesn't need two paths because no id w/periods
  # putting these paths at the end or else they suck through all the other people paths (because of the period constraint override)
  get 'people/:id', to: 'people#show', :constraints => { :id => with_period_ext}
  get 'people/:id', to: 'people#show', as: :person, :constraints => { :id => with_period }

  # families
  get 'families', to: 'families#index', as: :family
  get 'families/:name', to: 'families#sub', as: :familySub, :constraints => { :name => with_period }

  # stories
  get 'stories', to: 'stories#index', as: :stories
  get 'stories/:name', to: 'stories#sub', as: :storiesSub, :constraints => { :name => with_period }
   
  # about
  get 'about', to: 'about#index', as: :about
  get 'about/:name', to: 'about#sub', as: :aboutSub, :constraints => { :name => with_period }

  # maps
  get 'maps', to: 'maps#index', as: :maps
  get 'maps/directory_dc', to: 'maps#directory_dc', as: :map_dc
  get 'maps/directory_dc_1834', to: 'maps#directory_dc_1834', as: :map_dc_1834
  
  # error handling
  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#server_error', via: :all
end
