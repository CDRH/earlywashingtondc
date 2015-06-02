Rails.application.routes.draw do
  
  root 'static#index'

  # static pages
  get 'index' => 'static#index'
  get 'about' => 'static#about', as: :about
  get 'interest' => 'static#interest', as: :interest
  get 'family' => 'static#family', as: :family

  # documents (browsing / searching)
  get 'documents' => 'documents#index', as: :documents
  get 'supplementary' => 'documents#supplementary', as: :doc_supplementary
  get 'doc/:id', to: 'documents#show', as: :doc, :constraints => { :id => /[^\/]+/ }
  match 'search', to: 'documents#search', as: :search, :constraints => { :id => /[^\/]+/ }, via: [:get, :post]

end
