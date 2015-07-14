with_period = /[^\/]+/
with_period_ext = /[^\/]+(?=(\.json)|(\.xml)|(\.html))+/

Rails.application.routes.draw do

  root 'static#index'

  # static pages
  get '/' => 'static#index', as: :home
  get 'interest' => 'static#interest', as: :interest
  


  # documents (browsing / searching)
  post 'browse' => 'documents#dropdown', as: :dropdown
  match 'documents' => 'documents#index', as: :documents, via: [:get, :post]
  get 'supplementary' => 'documents#supplementary', as: :doc_supplementary
  get 'doc/:id', to: 'documents#show', as: :doc, :constraints => { :id => with_period }
  
  # search
  get 'advancedsearch' => 'documents#advancedsearch', as: :advancedsearch
  match 'search', to: 'documents#search', as: :search, :constraints => { :id => with_period }, via: [:get, :post]

  # cases
  get 'cases' => 'cases#index', as: :cases
  get 'cases/annotated' => 'cases#annotated', as: :casesAnnotated
  get 'cases/all' => 'cases#all', as: :casesAll
  get 'cases/documents' => 'cases#documents', as: :casesDocuments
  # in case cases ever have their own page
  get 'cases/:id' => 'cases#show', as: :case, :constraints => { :id => with_period }

  # people
  match 'people', to: 'people#index', as: :people, via: [:get, :post]
  match 'people/all', to: 'people#all', as: :peopleAll, via: [:get, :post]
  get 'people/:id', to: 'people#show', as: :person, :constraints => { :id => with_period }
  # I don't want to talk about this.  Due to sucking at regex, I never figured out a way to
  # capture ONLY the id regardless of whether there was an extension or not, so I just wrote two routes.
  get 'people/network/:id', to: 'people#network', :constraints => { :id => with_period_ext}
  get 'people/network/:id', to: 'people#network', as: :network_vis, :constraints => { :id => with_period }
  get 'test', to: 'people#test'

  # kinship
  get 'kinship', to: 'kinship#index', as: :kinship
  get 'kinship/:name', to: 'kinship#sub', as: :kinshipSub, :constraints => { :name => with_period }

#   # stories
   get 'stories', to: 'stories#index', as: :stories
   get 'stories/:name', to: 'stories#sub', as: :storiesSub, :constraints => { :name => with_period }
   
#   # about
     
   get 'about', to: 'about#index', as: :about
   get 'about/:name', to: 'about#sub', as: :aboutSub, :constraints => { :name => with_period }
  

end

#Stuff to delete later but keep around for reference for now -KD

# Old kinship
  #get 'kinship' => 'static#kinship', as: :kinship
  # temporarily putting family stuff in here until such time as it becomes generated?
  #get 'kinship/family/:id' => 'static#family', as: :family, :constraints => { :id => /[^\/]+/ }
  
  
#    get 'about/credits' => 'about#credits', as: :ab_credits
#   get 'about/data' => 'about#data', as: :ab_data
#   get 'about/description' => 'about#description', as: :ab_desc
#   get 'about/technical' => 'about#technical', as: :ab_tech

  # this will have to be removed
  #get 'family/:id' => 'static#family2', as: :family2, :constraints => { :id => /[^\/]+/ }

#   
#   
#   
#     # kinship
#   get 'kinship', to: 'kinship#index', as: :kinship
#   get 'kinship/:name', to: 'kinship#sub', as: :family, :constraints => { :name => /[^\/]+/ }
# 
#   # stories
#   get 'stories', to: 'stories#index', as: :stories
#   get 'stories/:name', to: 'stories#sub', as: :story, :constraints => { :name => /[^\/]+/ }
#   
# 
