# frozen_string_literal: true

require 'api_constraints'

Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: 'static_pages#home'

  get 'static_pages/home' => 'static_pages#home'

  # get 'async/donations' => 'async/donations#get'

  namespace :async, defaults: { format: 'json' } do
    resources :donations, only: [:index]
    resources :visits, only: [:index]
  end

  namespace :api, defaults: { format: 'json' } do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      resources :abstract_web_objects, only: [:create]
      resources :users, except: %i[index new edit], param: :avatar_key
      namespace :rezzable do
        resources :web_objects, except: %i[index new edit]
        resources :terminals, except: %i[index new edit]
        resources :servers, except: %i[new edit]
        resources :donation_boxes, except: %i[index new edit]
        resources :traffic_cops, except: %i[index new edit]
      end
      namespace :analyzable do
        resources :inventories, except: %i[new edit]
      end
    end
  end
end
