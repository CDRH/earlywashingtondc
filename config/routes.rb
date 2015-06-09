Rails.application.routes.draw do
  

  root 'static#index'

  # static pages
  get '/' => 'static#index', as: :home
  get 'about' => 'static#about', as: :about
  get 'interest' => 'static#interest', as: :interest
  get 'families' => 'static#families', as: :families
  # temporarily putting family stuff in here until such time as it becomes generated?
  get 'family/:id' => 'static#family', as: :family, :constraints => { :id => /[^\/]+/ }

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

end
