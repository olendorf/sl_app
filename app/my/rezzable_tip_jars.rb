# frozen_string_literal: true

ActiveAdmin.register Rezzable::TipJar, namespace: :my, as: 'Tip Jar' do
  include ActiveAdmin::RezzableBehavior

  menu parent: 'Objects', label: 'Tip Jars', if: proc { current_user.tip_jars.size.positive? }

  actions :all, except: %i[new create]

  decorate_with Rezzable::TipJarDecorator

  scope_to :current_user, association_method: :tip_jars

  filter :abstract_web_object_object_name, as: :string, label: 'Object Name'
  filter :abstract_web_object_description, as: :string, label: 'Description'
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
      link_to tip_jar.object_name, my_tip_jar_path(tip_jar)
    end
    column 'Description' do |tip_jar|
      truncate(tip_jar.description, length: 10, separator: ' ')
    end
    column 'Location', sortable: :region, &:slurl
    column 'Server', sortable: 'server.object_name' do |tip_jar|
      link_to tip_jar.server.object_name,
              my_server_path(tip_jar.server) if tip_jar.server
    end
    column 'Current User' do |tip_jar|
      if tip_jar.current_session
        "#{tip_jar.current_session.avatar_name} (#{tip_jar.time_logged_in} mins)"
      else
        'Empty'
      end
    end
    
    column 'Hover Text Color' do |tip_jar|
      tip_jar.color_box
    end

    # column 'Total Donations', &:total_donations
    # column :goal
    # column :dead_line
    column 'Version', &:semantic_version
    column :status, &:pretty_active

    column :created_at, sortable: :created_at
    actions
  end

  sidebar :settings, only: %i[edit show] do
    attributes_table do
      row :thank_you_message
      row :split_percent
      row 'Sensor Mode' do |tip_jar|
        tip_jar.sensor_mode.split('_').last.humanize
      end
      row 'Access Mode' do |tip_jar|
        tip_jar.access_mode.split('_').last.humanize
      end
      row 'Hover Text Color'  do |tip_jar|
        tip_jar.color_box
      end
      row :show_hover_text
      row :show_total
      row :show_last_tip
      row :show_last_tipper
      row :show_duration
    end
  end

  show title: :object_name do
    attributes_table do
      row :object_name, &:object_name
      row :object_key, &:object_key
      row :description
      row 'Server' do |tip_jar|
        if tip_jar.server
          link_to tip_jar.server.object_name, my_server_path(tip_jar.server)
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

  #   panel 'Top 10 Donors For This Box' do
  #     counts = resource.transactions.group(:target_name).count
  #     sums = resource.transactions.group(:target_name).order('sum_amount DESC').sum(:amount)
  #     data = sums.collect { |k, v| { donor: k, amount: v, count: counts[k] } }
  #     paginated_data = Kaminari.paginate_array(data).page(params[:donor_page]).per(10)

  #     table_for paginated_data do
  #       column :donor
  #       column :amount
  #       column('Donations') do |item|
  #         item[:count]
  #       end
  #     end
  #   end
  # end

  # sidebar :donations, only: :show do
  #   paginated_collection(
  #     resource.transactions.page(
  #       params[:donation_page]
  #     ).per(10), param_name: 'donation_page'
  #   ) do
  #     table_for collection.order(created_at: :desc).decorate, download_links: false do
  #       column :created_at
  #       column 'Payer/Payee', &:target_name
  #       column :amount
  #     end
  #   end
  # end

  permit_params :object_name, :description, :server_id, :access_mode, :thank_you_message

  form title: proc { "Edit #{resource.object_name}" } do |f|
    f.inputs do
      if resource.user
        f.input :object_name, label: 'Donation Box name'
        f.input :description
        f.input :split_percent
        f.input :server_id, as: :select, collection: resource.user.servers.map { |s|
          [s.object_name, s.actable.id]
        }
        f.input :access_mode, as: :select,
                              include_blank: false,
                              collection: Rezzable::TipJar.access_modes.collect { |k, _v|
                                            [k.split('_').last.titleize, k]
                                          }
        f.input :sensor_mode, as: :select,
                              include_blank: false,
                              collection: Rezzable::TipJar.sensor_modes.collect { |k, _v|
                                            [k.split('_').last.titleize, k]
                                          }
        f.input :thank_you_message
        f.input :hover_text_color, as: :color
        f.input :show_hover_text
        f.input :show_total
        f.input :show_last_tip
        f.input :show_last_tipper
        f.input :show_duration
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
