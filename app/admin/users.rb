# frozen_string_literal: true

ActiveAdmin.register User do
  index do
    selectable_column
    column :avatar_name do |user|
      link_to user.avatar_name, admin_user_path(user)
    end
    column :role do |user|
      user.role.capitalize
    end
    column :account_level
    column :expiration_date
    column 'Object Count' do |user|
      user.web_objects.size
    end
    column 'Split Percent', &:split_percent
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

  permit_params :role, :expiration_date, :account_level, :admin_update

  form do |f|
    f.inputs do
      f.input :role, include_blank: false
      f.input :account_level
      f.input :expiration_date
      f.input :admin_update, input_html: { value: 1 }, as: :hidden
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
      row :account_level
      row :expiration_date
      row 'Object Count' do |user|
        user.web_objects.size
      end
      row 'Split Percent', &:split_percent
      row :remember_created_at
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
      row :created_at
      row :updated_at
    end
  end
end
