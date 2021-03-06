Rails.application.routes.draw do

  root "notes#index"

  post 'search', to: 'search#index'
  get 'help', to: 'pages#help', as: 'pages_help'

  resource :account, only: [:show, :update]

  resources :backups, only: [:index, :start] do 
    get '/index', to: 'backups#index'
    get '/start', to: 'backups#start', on: :collection, as: :start
  end

  resources :notes, param: :guid do
    get '/make_public', to: 'notes#make_public', on: :member
    get '/make_private', to: 'notes#make_private', on: :member
    delete '/attachment/:id', to: 'notes#delete_attachment', on: :member, as: :delete_attachment
  end

  get '/public/:guid', to: 'notes#public', params: :guid, as: :public_note

  devise_for :users, controllers: {
    registrations: "registrations",
    passwords: "passwords"}

  resources :categories, param: :slug
  resources :tags, param: :name

  get '/wiki', to: 'categories#wiki'
  get '/download', to: 'downloads#export_zip', as: 'download_export_zip'

  # Imports
  get '/import', to: 'imports#wizard', as: 'import_wizard'
  post '/import', to: 'imports#import_zip', as: 'import_zip'
  get '/show', to: 'imports#show', as: 'import_show'

  if Rails.env.development?
    require 'sidekiq/web'
    require 'sidekiq-status/web'
    authenticate :user do
      mount Sidekiq::Web => '/sidekiq'
    end
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # Direct URLs
  direct :official_homepage_repo do
    "https://wreeto.com"
  end
  direct :official_github_repo do
    "https://github.com/chrisvel/wreeto_official"
  end

  # ActiveStorage hack 
  get '*all', to: 'application#not_found', constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage'
  }
end
