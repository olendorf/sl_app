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
    column :split_percent
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

  permit_params :role,
                :expiration_date,
                :account_level,
                :admin_update,
                splits_attributes: %i[id target_name target_key percent _destroy]

  form do |f|
    f.inputs do
      f.input :role, include_blank: false
      f.input :account_level
      f.input :expiration_date, as: :datetime_picker
      f.input :admin_update, input_html: { value: 1 }, as: :hidden

      f.has_many :splits, heading: 'Splits',
                          allow_destroy: true do |s|
        s.input :target_name, label: 'Avatar Name'
        s.input :target_key, label: 'Avatar Key'
        s.input :percent
      end
    end
    f.actions
  end

  sidebar :splits, only: %i[show edit] do
    total = 0
    ul class: 'row' do
      resource.splits.each do |split|
        total += split.percent
        li "#{split.target_name}: #{split.percent}%"
      end
      hr
      li "Total: #{total}%"
    end
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

  controller do
    def scoped_collection
      super.includes(%i[splits])
    end
  end
end
