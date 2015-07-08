Rails.application.routes.draw do
  

  root 'static#index'

  # static pages
  get '/' => 'static#index', as: :home
  get 'interest' => 'static#interest', as: :interest
  get 'kinship' => 'static#kinship', as: :kinship
  # temporarily putting family stuff in here until such time as it becomes generated?
  get 'kinship/family/:id' => 'static#family', as: :family, :constraints => { :id => /[^\/]+/ }
  # this will have to be removed
  get 'family/:id' => 'static#family2', as: :family2, :constraints => { :id => /[^\/]+/ }

  # about
  get 'about' => 'about#index', as: :about
  get 'about/credits' => 'about#credits', as: :ab_credits
  get 'about/data' => 'about#data', as: :ab_data
  get 'about/description' => 'about#description', as: :ab_desc
  get 'about/technical' => 'about#technical', as: :ab_tech

  # documents (browsing / searching)
  post 'browse' => 'documents#dropdown', as: :dropdown
  match 'documents' => 'documents#index', as: :documents, via: [:get, :post]
  get 'supplementary' => 'documents#supplementary', as: :doc_supplementary
  get 'doc/:id', to: 'documents#show', as: :doc, :constraints => { :id => /[^\/]+/ }
  match 'search', to: 'documents#search', as: :search, :constraints => { :id => /[^\/]+/ }, via: [:get, :post]

  # cases
  get 'cases' => 'cases#index', as: :cases
  # in case cases ever have their own page
  get 'case/:id' => 'cases#show', as: :case, :constraints => { :id => /[^\/]+/ }

  # people
  match 'people', to: 'people#index', as: :people, via: [:get, :post]
  get 'person/:id', to: 'people#show', as: :person, :constraints => { :id => /[^\/]+/ }
  get 'test', to: 'people#test'

  # stories
  get 'stories', to: 'stories#index', as: :stories
  get 'story/:name', to: 'stories#story', as: :story, :constraints => { :name => /[^\/]+/ }
end
