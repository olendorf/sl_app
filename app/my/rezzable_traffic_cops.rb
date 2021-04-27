# frozen_string_literal: true

ActiveAdmin.register Rezzable::TrafficCop, as: 'Traffic Cop', namespace: :my do
  include ActiveAdmin::RezzableBehavior

  menu if: proc { current_user.traffic_cops.size.positive? }, label: 'Traffic Cops'

  actions :all, except: %i[new create]

  decorate_with Rezzable::TrafficCopDecorator

  scope_to :current_user, association_method: :traffic_cops

  index title: 'Traffic Cops' do
    selectable_column
    column 'Power' do |traffic_cop|
      traffic_cop.decorate.pretty_power
    end
    column 'Object Name', sortable: :object_name do |traffic_cop|
      link_to traffic_cop.object_name, my_traffic_cop_path(traffic_cop)
    end
    column 'Description', sortable: :description do |traffic_cop|
      truncate(traffic_cop.description, length: 10, separator: ' ')
    end
    column 'Location', sortable: :region, &:slurl
    column 'Server', sortable: 'server.object_name' do |traffic_cop|
      link_to traffic_cop.server.object_name,
              my_server_path(traffic_cop.server) if traffic_cop.server
    end

    column 'Current Visitors' do |traffic_cop|
      traffic_cop.current_visitors.size
    end

    column 'Recent Visitors' do |traffic_cop|
      traffic_cop.visits.where('stop_time > ?', 1.week.ago).size
    end

    column 'Recent Time Spent (mins)' do |traffic_cop|
      traffic_cop.visits.where('stop_time > ?', 1.week.ago).sum(:duration) / 60
    end

    actions
  end

  filter :abstract_web_object_object_name, as: :string, label: 'Object Name'
  filter :abstract_web_object_description, as: :string, label: 'Description'
  filter :abstract_web_object_region, as: :string, label: 'Region'
  filter :web_object_pinged_at, as: :date_range, label: 'Last Ping'

  sidebar :settings, only: %i[edit show] do
    attributes_table do
      # row :power
      row 'Power' do |traffic_cop|
        traffic_cop.decorate.pretty_power
      end
      row 'Sensor mode' do |traffic_cop|
        traffic_cop.decorate.pretty_sensor_mode
      end
      row 'Security mode' do |traffic_cop|
        traffic_cop.decorate.pretty_security_mode
      end
      row 'Access mode' do |traffic_cop|
        traffic_cop.decorate.pretty_access_mode
      end
      row :first_visit_message
      row :repeat_visit_message
      row :inventory_to_give
    end
  end

  sidebar :current_visitors, only: %i[edit show] do
    paginated_collection(
      resource.current_visitors.order(duration: :desc).page(
        params[:current_page]
      ).per(10), param_name: 'current_page', download_links: false
    ) do
      table_for collection do
        column :avatar_name
        column :start_time
        column 'Duration' do |visit|
          "#{visit.duration / 60.0} mins"
        end
      end
    end
  end

  sidebar :allowed, only: %i[edit show] do
    paginated_collection(
      resource.allowed_list.order(:avatar_name).page(
        params[:allowed_page]
      ).per(10), param_name: 'allowed_page', download_links: false
    ) do
      table_for collection do
        column :avatar_name
        column '' do |avatar|
          link_to 'Delete',  my_listable_avatar_path(avatar),
                  method: :delete,
                  data: { confirm: 'Delete this allowed avatar?' }
        end
      end
    end

    render partial: 'add_listable_form', locals: { list_name: 'allowed' }
  end

  sidebar :banned, only: %i[edit show] do
    paginated_collection(
      resource.banned_list.order(:avatar_name).page(
        params[:banned_page]
      ).per(10), param_name: 'banned_page', download_links: false
    ) do
      table_for collection do
        column :avatar_name
        column '' do |avatar|
          link_to 'Delete',  my_listable_avatar_path(avatar),
                  method: :delete,
                  data: { confirm: 'Unban this avatar?' }
        end
      end
    end

    render partial: 'add_listable_form', locals: { list_name: 'banned' }
  end

  show title: :object_name do
    attributes_table do
      row :server_name, &:object_name
      row :server_key, &:object_key
      row :description
      row :location, &:slurl
      row 'Recent Visitors' do
        traffic_cop.visits.where('stop_time > ?', 1.week.ago).size
      end
      row 'Recent Time Spent' do
        traffic_cop.visits.where('stop_time > ?', 1.week.ago).sum(:duration) / 60
      end
    end

    panel 'Visits' do
      paginated_collection(
        resource.visits.order(start_time: :desc).page(
          params[:visit_page]
        ).per(20), param_name: 'visit_page', download_links: false
      ) do
        table_for collection do
          column :avatar_name
          column :avatar_key
          column :start_time
          column :stop_time
          column 'Duration (mins)' do |visit|
            visit.duration / 60.0
          end
        end
      end
    end

    panel 'Visitors' do
      data = resource.visitors
      paginated_data = Kaminari.paginate_array(data).page(params['visitor_page']).per(20)
      div class: 'paginated_collection' do
        table_for paginated_data do
          column :avatar_name
          column :avatar_key
          column :visits
          column 'Time Spent (mins)' do |visitor|
            visitor[:time_spent] / 60.0
          end
        end
        div id: 'visitors-footer' do
          paginate paginated_data, param_name: 'visitor_page'
        end
        div class: 'pagination_information' do
          page_entries_info paginated_data, entry_name: 'Visitors'
        end
      end
    end

    panel '' do
      div class: 'column lg' do
        render partial: 'visits_timeline'
      end
    end

    panel '' do
      div class: 'column md' do
        render partial: 'visits_histogram'
      end
      div class: 'column md' do
        render partial: 'visitors_time_histogram'
      end
    end

    panel '' do
      div class: 'column md' do
        render partial: 'visitors_counts_histogram'
      end

      div class: 'column md' do
        render partial: 'visitor_counts_duration_scatter'
      end
    end

    panel '' do
      div class: 'column md' do
        render partial: 'visits_heatmap'
      end

      div class: 'column md' do
        render partial: 'duration_heatmap'
      end
    end

    panel '' do
      div class: 'column centered' do
        render partial: 'visit_location_heatmap'
      end

      # div class: 'column md' do
      #   render partial: 'duration_heatmap'
      # end
    end
  end

  permit_params :object_name, :description, :server_id, :power, :sensor_mode,
                :security_mode, :access_mode, :first_visit_message,
                :repeat_visit_message

  form title: proc { "Edit #{resource.object_name}" } do |f|
    f.inputs do
      f.input :object_name, label: 'Donation Box name'
      f.input :description
      f.input :server_id, as: :select, collection: resource.user.servers.map { |s|
        [s.object_name, s.actable.id]
      }
      f.input :power
      f.input :sensor_mode, as: :select,
                            collection: Rezzable::TrafficCop.sensor_modes.collect { |k, _v|
                              [k.split('_')[2..].join(' ').titleize, k]
                            },
                            selected: resource.sensor_mode,
                            include_blank: false
      f.input :security_mode, as: :select,
                              collection: Rezzable::TrafficCop.security_modes.collect { |k, _v|
                                [k.split('_')[2..].join(' ').titleize, k]
                              },
                              selected: resource.security_mode,
                              include_blank: false
      f.input :access_mode, as: :select,
                            collection: Rezzable::TrafficCop.access_modes.collect { |k, _v|
                              [k.split('_')[2..].join(' ').titleize, k]
                            },
                            selected: resource.access_mode,
                            include_blank: false
      f.input :first_visit_message
      f.input :repeat_visit_message
    end
    f.actions
  end

  controller do
    def show
      gon.ids = [resource.id]
      super
    end
  end
end
