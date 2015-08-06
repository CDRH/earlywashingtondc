with_period = /[^\/]+/
with_period_ext = /[^\/]+(?=(\.json)|(\.xml)|(\.html))+/

Rails.application.routes.draw do

  root 'static#index'

  # static pages
  get '/' => 'static#index', as: :home
  get 'interest' => 'static#interest', as: :interest

  # documents (browsing / searching)
  post 'browse' => 'documents#dropdown', as: :doc_dropdown
  get 'doc/:id', to: 'documents#show', as: :doc, :constraints => { :id => with_period }
  
  # search
  get 'advancedsearch' => 'documents#advancedsearch', as: :advancedsearch
  match 'search', to: 'documents#search', as: :search, :constraints => { :id => with_period }, via: [:get, :post]

  # cases
  get 'cases' => 'cases#index', as: :cases
  match 'cases/annotated' => 'cases#annotated', as: :casesAnnotated, via: [:get, :post]
  match 'cases/all' => 'cases#all', as: :casesAll, via: [:get, :post]
  match 'cases/documents' => 'documents#index', as: :documents, via: [:get, :post]
  get 'cases/:id' => 'cases#show', as: :case, :constraints => { :id => with_period }

  # people
  match 'people', to: 'people#index', as: :people, via: [:get, :post]
  match 'people/all', to: 'people#all', as: :peopleAll, via: [:get, :post]
  # I don't want to talk about this.  Due to sucking at regex, I never figured out a way to
  # capture ONLY the id regardless of whether there was an extension or not, so I just wrote two routes.
  get 'people/:id', to: 'people#show', :constraints => { :id => with_period_ext}
  get 'people/:id', to: 'people#show', as: :person, :constraints => { :id => with_period }
  get 'people/network/:id', to: 'people#network', :constraints => { :id => with_period_ext}
  get 'people/network/:id', to: 'people#network', as: :network_vis, :constraints => { :id => with_period }
  post 'people/browse', to: 'people#browse', as: :person_browse, :constraints => { :id => with_period }

  # kinship
  get 'kinship', to: 'kinship#index', as: :kinship
  get 'kinship/:name', to: 'kinship#sub', as: :kinshipSub, :constraints => { :name => with_period }

  # stories
  get 'stories', to: 'stories#index', as: :stories
  get 'stories/:name', to: 'stories#sub', as: :storiesSub, :constraints => { :name => with_period }
   
  # about
  get 'about', to: 'about#index', as: :about
  get 'about/:name', to: 'about#sub', as: :aboutSub, :constraints => { :name => with_period }
  
  # error handling
  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#server_error', via: :all

end