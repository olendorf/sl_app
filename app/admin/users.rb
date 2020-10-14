# frozen_string_literal: true

ActiveAdmin.register User do
  permit_params :role

  index do
    selectable_column
    column :avatar_name
    column :role do |user|
      user.role.capitalize
    end
    column 'Object Count' do |user|
      user.abstract_web_objects.size
    end
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    column :updated_at
    actions
  end

  filter :avatar_name
  filter :role, as: :check_boxes, collection: User.roles
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

  show title: :avatar_name do
    attributes_table do
      row :avatar_name
      row :avatar_key
      row 'Role' do |user|
        user.role.capitalize
      end
      row 'Object Count' do |user|
        user.abstract_web_objects.size
      end
      row :remember_created_at
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
      row :created_at
      row :updated_at
    end
  end
end
