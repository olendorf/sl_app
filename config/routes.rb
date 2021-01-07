# frozen_string_literal: true

require 'api_constraints'

Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: 'static_pages#home'

  get 'static_pages/home' => 'static_pages#home'

  namespace :api, defaults: { format: 'json' } do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      resources :abstract_web_objects, only: [:create]
      resources :users, except: %i[index new edit], param: :avatar_key
      namespace :rezzable do
        resources :web_objects, except: %i[index new edit]
        resources :terminals, except: %i[index new edit]
      end
    end
  end
end
