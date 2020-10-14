# frozen_string_literal: true

ActiveAdmin.register User do
  permit_params :role

  index do
    selectable_column
    column :avatar_name
    column :role
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    column :updated_at
    actions
  end
  
  filter :avatar_name
  filter :role
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs do
      f.input :role, include_blank: false
    end
    f.actions
  end
end
