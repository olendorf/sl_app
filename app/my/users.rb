# frozen_string_literal: true

ActiveAdmin.register User, namespace: :my do
  menu false

  actions :edit, :show, :update

  show title: :avatar_name do
    attributes_table do
      row :avatar_name
      row :avatar_key
      row :role
      row :account_level
      row :object_weight
      row :expiration_date
      row :remember_created_at
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
      row :created_at
      row :updated_at
    end
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

  permit_params splits_attributes: %i[id target_name
                                      target_key percent _destroy]

  form title: proc { "Edit #{resource.avatar_name}" } do |f|
    f.has_many :splits, heading: 'Splits',
                        allow_destroy: true do |s|
      s.input :target_name, label: 'Avatar Name'
      s.input :target_key, label: 'Avatar Key'
      s.input :percent
    end
    f.actions do
      f.action :submit
      f.cancel_link(action: 'index', controller: 'my/dashboard')
    end
  end

  controller do
    def update
      update! do |format|
        format.html { redirect_to(my_dashboard_path) }
      end
    end
  end
end
