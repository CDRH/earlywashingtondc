Rails.application.routes.draw do
  
  root 'static#index'

  # static pages
  get 'index' => 'static#index', as: :home
  get 'about' => 'static#about', as: :about
  get 'interest' => 'static#interest', as: :interest
  get 'families' => 'static#families', as: :families
  get 'family/:id' => 'static#family', as: :family, :constraints => { :id => /[^\/]+/ }
  # temporarily putting family stuff in here until such time as it becomes generated?

  # documents (browsing / searching)
  post 'browse' => 'documents#dropdown', as: :dropdown
  get 'documents' => 'documents#index', as: :documents
  get 'supplementary' => 'documents#supplementary', as: :doc_supplementary
  get 'doc/:id', to: 'documents#show', as: :doc, :constraints => { :id => /[^\/]+/ }
  match 'search', to: 'documents#search', as: :search, :constraints => { :id => /[^\/]+/ }, via: [:get, :post]


end
