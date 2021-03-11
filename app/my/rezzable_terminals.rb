# frozen_string_literal: true

ActiveAdmin.register Rezzable::Terminal, as: 'Terminal', namespace: :my do
  include ActiveAdmin::RezzableBehavior

  menu false

  actions :all, except: %i[new create index]

  scope_to :current_user, association_method: :terminals

  decorate_with Rezzable::TerminalDecorator

  # index title: 'Terminals' do
  #   selectable_column
  #   column 'Object Name', sortable: :object_name do |terminal|
  #     link_to terminal.object_name, admin_terminal_path(terminal)
  #   end
  #   column 'Description' do |terminal|
  #     truncate(terminal.description, length: 10, separator: ' ')
  #   end
  #   column 'Location', sortable: :region, &:slurl
  #   column 'Server', sortable: 'server.object_name' do |terminal|
  #     if terminal.server
  #       link_to terminal.server.object_name, admin_server_path(terminal.server)
  #     else
  #       nil
  #     end
  #   end
  #   column 'Owner', sortable: 'users.avatar_name' do |terminal|
  #     if terminal.user
  #       link_to terminal.user.avatar_name, admin_user_path(terminal.user)
  #     else
  #       'Orphan'
  #     end
  #   end
  #   column 'Version', &:semantic_version
  #   column :sttus, &:pretty_active
  #   # column 'Last Ping', sortable: :pinged_at do |terminal|
  #   #   if terminal.active?
  #   #     status_tag 'active', label: time_ago_in_words(terminal.pinged_at)
  #   #   else
  #   #     status_tag 'inactive', label: time_ago_in_words(terminal.pinged_at)
  #   #   end
  #   # end
  #   column :created_at, sortable: :created_at
  #   actions
  # end

  # filter :abstract_web_object_object_name, as: :string, label: 'Object Name'
  # filter :abstract_web_object_description, as: :string, label: 'Description'
  # filter :abstract_web_object_user_avatar_name, as: :string, label: 'Owner'
  # filter :abstract_web_object_region, as: :string, label: 'Region'
  # # filter :web_object_pinged_at, as: :date_range, label: 'Last Ping'
  # filter :abstract_web_object_create_at, as: :date_range

  show title: :object_name do
    attributes_table do
      row :terminal_name, &:object_name
      row :terminal_key, &:object_key
      row :description
      row 'Owner', sortable: 'users.avatar_name' do |terminal|
        if terminal.user
          link_to terminal.user.avatar_name, admin_user_path(terminal.user)
        else
          'Orphan'
        end
      end
      row :location, &:slurl
      row 'Server' do |terminal|
        if terminal.server
          link_to terminal.server.object_name, admin_server_path(terminal.server)
        else
          ''
        end
      end
      row :created_at
      row :updated_at
      row :pinged_at
      row :version, &:semantic_version
      row :status, &:pretty_active
      # row :status do |terminal|
      #   if terminal.active?
      #     status_tag 'active', label: 'Active'
      #   else
      #     status_tag 'inactive', label: 'Inactive'
      #   end
      # end
    end
  end

  # sidebar :splits, only: %i[show edit] do
  #   dl class: 'row' do
  #     resource.splits.each do |split|
  #       dt split.target_name
  #       dd "#{number_with_precision(split.percent, precision: 2)}%"
  #     end
  #   end
  # end

  permit_params :object_name, :description, :server_id,
                splits_attributes: %i[id target_name
                                      target_key percent _destroy]

  form title: proc { "Edit #{resource.object_name}" } do |f|
    f.inputs do
      f.input :object_name, label: 'Terminal name'
      f.input :description
      if resource.user
        f.input :server_id, as: :select, collection: resource.user.servers.map { |s|
                                                       [s.object_name, s.actable.id]
                                                     }
      end
    end
    # f.has_many :splits, heading: 'Splits',
    #                     allow_destroy: true do |s|
    #   s.input :target_name, label: 'Avatar Name'
    #   s.input :target_key, label: 'Avatar Key'
    #   s.input :percent
    # end
    f.actions
  end

  # controller do
  #   # def scoped_collection
  #   #   super.includes :user
  #   # end
  # end
end
