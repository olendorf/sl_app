# frozen_string_literal: true

ActiveAdmin.register Rezzable::DonationBox, namespace: :my, as: 'Donation Box' do
  include ActiveAdmin::RezzableBehavior

  menu parent: 'Objects', label: 'Donation Boxes', if: proc {
                                                         current_user.donation_boxes.size.positive?
                                                       }

  actions :all, except: %i[new create]

  decorate_with Rezzable::DonationBoxDecorator

  scope_to :current_user, association_method: :donation_boxes

  filter :abstract_web_object_object_name, as: :string, label: 'Object Name'
  filter :abstract_web_object_description, as: :string, label: 'Description'
  filter :abstract_web_object_region, as: :string, label: 'Region'
  filter :web_object_pinged_at, as: :date_range, label: 'Last Ping'
  filter :abstract_web_object_create_at, as: :date_range
  filter :goal
  filter :dead_line, as: :date_range
  filter :show_last_donation, as: :check_boxes
  filter :show_last_donor, as: :check_boxes
  filter :show_largest_donation, as: :check_boxes
  filter :show_total, as: :check_boxes
  filter :show_biggest_donor, as: :check_boxes

  index title: 'Donation Boxes' do
    selectable_column
    column 'Object Name', sortable: :object_name do |donation_box|
      link_to donation_box.object_name, my_donation_box_path(donation_box)
    end
    column 'Description' do |donation_box|
      truncate(donation_box.description, length: 10, separator: ' ')
    end
    column 'Location', sortable: :region, &:slurl
    column 'Server', sortable: 'server.object_name' do |donation_box|
      link_to donation_box.server.object_name,
              my_server_path(donation_box.server) if donation_box.server
    end
    column 'Total Donations', &:total_donations
    column :goal
    column :dead_line
    column 'Version', &:semantic_version
    column :status, &:pretty_active

    column :created_at, sortable: :created_at
    actions
  end

  sidebar :settings, only: %i[edit show] do
    attributes_table do
      row :show_last_donation
      row :show_last_donor
      row :show_total
      row :show_largest_donation
      row :show_biggest_donor
      row :goal
      row :dead_line
    end
  end

  show title: :object_name do
    attributes_table do
      row :donation_box_name, &:object_name
      row :object_key
      row :description
      row :location, &:slurl
      row 'Server' do |donation_box|
        link_to donation_box.server.object_name,
                my_server_path(donation_box.server) if donation_box.server
      end
      row :total_donations
      row 'Largest Donation' do |db|
        donation = db.largest_donation
        "#{donation['target_name']}: L$ #{donation['amount']} (#{donation['created_at']}})"
      end
      row 'Biggest Donor' do |db|
        donor = db.biggest_donor
        "#{donor[:avatar_name]}: L$ #{donor[:amount]}"
      end
      row :created_at
      row :updated_at
      row :pinged_at
      row :version, &:semantic_version
      row :status, &:pretty_active
    end

    panel 'Donors For This Box' do
      counts = resource.transactions.group(:target_name).count
      sums = resource.transactions.group(:target_name).order('sum_amount DESC').sum(:amount)
      data = sums.collect { |k, v| { donor: k, amount: v, count: counts[k] } }
      paginated_data = Kaminari.paginate_array(data).page(params[:donor_page]).per(10)

      table_for paginated_data, sortable: true do
        column :donor
        column :amount
        column('Donations') do |item|
          item[:count]
        end
      end

      div id: 'donors-footer' do
        paginate paginated_data, param_name: :donor_page
      end

      div class: 'pagination-information' do
        page_entries_info paginated_data, entry_name: 'donation'
      end
    end
  end

  sidebar :donations, only: :show do
    paginated_collection(
      resource.transactions.page(
        params[:donation_page]
      ).per(10), param_name: 'donation_page'
    ) do
      table_for collection.order('created_at DESC').decorate, download_links: false do
        column 'Date/time', &:created_at
        column 'Payer/Payee', &:target_name
        column :amount
      end
    end
  end

  permit_params :object_name, :description, :show_last_donation, :show_last_donor,
                :show_total, :show_largest_donation, :show_biggest_donor, :goal,
                :dead_line, :response, :server_id

  form title: proc { "Edit #{resource.object_name}" } do |f|
    f.inputs do
      if resource.user
        f.input :object_name, label: 'Donation Box name'
        f.input :description
        f.input :server_id, as: :select, collection: resource.user.servers.map { |s|
          [s.object_name, s.actable.id]
        }
        f.input :show_largest_donation
        f.input :show_last_donor
        f.input :show_total
        f.input :show_largest_donation
        f.input :goal, as: :number,
                       input_html: {
                         min: 0,
                         step: 1
                       }
        f.input :dead_line, as: :datetime_picker
        f.input :response
      end
      f.actions
    end
  end

  controller do
    # def scoped_collection
    # super.includes(%i[transactions])
    # end
  end
end
