# frozen_string_literal: true

require 'api_constraints'
require 'sidekiq/web'

Rails.application.routes.draw do
  get 'background_jobs/give_inventory'
  match '/404', to: 'errors#not_found', via: :all
  match '/400', to: 'errors#bad_request', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all

  get 'public/available_parcels'
  get 'public/my_parcels'
  get 'public/my_purchases'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: 'pages#home'

  get 'pages/home' => 'pages#home'
  get 'pages/products' => 'pages#products'
  get 'pages/pricing' => 'pages#pricing'
  get 'pages/documentation' => 'pages#documentation'
  get 'pages/faqs' => 'pages#faqs'

  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  mount Sidekiq::Web => '/sidekiq'

  namespace :async, defaults: { format: 'json' } do
    resources :donations, only: [:index]
    resources :visits, only: [:index]
    resources :tips, only: [:index]
    resources :sales, only: [:index]
    resources :rentals, only: [:index]
  end

  namespace :api, defaults: { format: 'json' } do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      resources :abstract_web_objects, only: [:create]
      resources :users, except: %i[index new edit], param: :avatar_key
      resources :service_tickets, except: %i[destroy edit new]
      namespace :rezzable do
        resources :web_objects, except: %i[index new edit]
        resources :terminals, except: %i[index new edit]
        resources :servers, except: %i[new edit]
        resources :donation_boxes, except: %i[index new edit]
        resources :traffic_cops, except: %i[index new edit]
        resources :tip_jars, except: %i[index new edit]
        resources :vendors, except: %i[index new edit]
        resources :parcel_boxes, except: %i[index new edit]
        resources :tier_stations, except: %i[index new edit]
        resources :shop_rental_boxes, except: %i[index new edit]
      end
      namespace :analyzable do
        resources :inventories, except: %i[new edit]
        resources :parcels, except: %i[new edit destroy]
      end
    end
  end
end
