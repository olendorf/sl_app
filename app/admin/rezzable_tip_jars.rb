# frozen_string_literal: true

ActiveAdmin.register Rezzable::TipJar, as: 'Tip Jar' do
  include ActiveAdmin::RezzableBehavior

  menu label: 'Tip Jars'

  actions :all, except: %i[new create]

  decorate_with Rezzable::TipJarDecorator

  filter :abstract_web_object_object_name, as: :string, label: 'Object Name'
  filter :abstract_web_object_description, as: :string, label: 'Description'
  filter :abstract_web_object_user_avatar_name, as: :string, label: 'Owner'
  filter :abstract_web_object_region, as: :string, label: 'Region'
  filter :web_object_pinged_at, as: :date_range, label: 'Last Ping'
  filter :abstract_web_object_create_at, as: :date_range
  # filter :goal
  # filter :dead_line, as: :date_range
  # filter :show_last_donation, as: :check_boxes
  # filter :show_last_donor, as: :check_boxes
  # filter :show_largest_donation, as: :check_boxes
  # filter :show_total, as: :check_boxes
  # filter :show_biggest_donor, as: :check_boxes

  index title: 'Tip Jars' do
    selectable_column
    column 'Object Name', sortable: :object_name do |tip_jar|
      link_to tip_jar.object_name, admin_tip_jar_path(tip_jar)
    end
    column 'Description' do |tip_jar|
      truncate(tip_jar.description, length: 10, separator: ' ')
    end
    column 'Location', sortable: :region, &:slurl
    column 'Server', sortable: 'server.object_name' do |tip_jar|
      link_to tip_jar.server.object_name,
              admin_server_path(tip_jar.server) if tip_jar.server
    end
    column 'Owner', sortable: 'users.avatar_name' do |tip_jar|
      if tip_jar.user
        link_to tip_jar.user.avatar_name, admin_user_path(tip_jar.user)
      else
        'Orphan'
      end
    end
    column 'Current User' do |tip_jar|
      if tip_jar.current_session
        "#{tip_jar.current_session.avatar_name} (#{tip_jar.time_logged_in} mins)"
      else
        'Empty'
      end
    end

    column 'Version', &:semantic_version
    column :status, &:pretty_active

    column :created_at, sortable: :created_at
    actions
  end

  show title: :object_name do
    attributes_table do
      row :object_name, &:object_name
      row :object_key, &:object_key
      row :description
      row 'Access Mode' do |tip_jar|
        tip_jar.access_mode.split('_').last.titleize
      end
      row :thank_you_message
      row 'Owner', sortable: 'users.avatar_name' do |tip_jar|
        if tip_jar.user
          link_to tip_jar.user.avatar_name, admin_user_path(tip_jar.user)
        else
          'Orphan'
        end
      end
      row 'Server' do |tip_jar|
        if tip_jar.server
          link_to tip_jar.server.object_name, admin_server_path(tip_jar.server)
        else
          ''
        end
      end
      row 'Current User' do |tip_jar|
        if tip_jar.current_session
          "#{tip_jar.current_session.avatar_name} (#{tip_jar.time_logged_in} mins)"
        else
          'Empty'
        end
      end
      row :location, &:slurl
      row :created_at
      row :updated_at
      row :pinged_at
      row :version, &:semantic_version
      row :status, &:pretty_active
    end
  end

  permit_params :object_name, :description, :server_id, :access_mode, :thank_you_message

  form title: proc { "Edit #{resource.object_name}" } do |f|
    f.inputs do
      if resource.user
        f.input :object_name, label: 'Donation Box name'
        f.input :description
        f.input :server_id, as: :select, collection: resource.user.servers.map { |s|
          [s.object_name, s.actable.id]
        }
        f.input :access_mode, as: :select,
                              include_blank: false,
                              collection: Rezzable::TipJar.access_modes.collect { |k, _v|
                                            [k.split('_').last.titleize, k]
                                          }
        f.input :thank_you_message
      end
      f.actions
    end
  end

  controller do
    # def scoped_collection
    #   # super.includes(%i[server user transactions])
    # end
  end
end
