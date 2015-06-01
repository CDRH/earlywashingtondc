Rails.application.routes.draw do
  
  root 'static#index'

  # static pages
  get 'index' => 'static#index'
  get 'about' => 'static#about', as: :about
  get 'interest' => 'static#interest', as: :interest
  get 'family' => 'static#family', as: :family

  # documents (browsing / searching)
  get 'documents' => 'documents#index', as: :documents

end
