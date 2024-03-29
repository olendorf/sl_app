# frozen_string_literal: true

ActiveAdmin.register Rezzable::DonationBox, as: 'Donation Box' do
  include ActiveAdmin::RezzableBehavior

  menu label: 'Donation Boxes'

  actions :all, except: %i[new create]

  decorate_with Rezzable::DonationBoxDecorator

  filter :abstract_web_object_object_name, as: :string, label: 'Object Name'
  filter :abstract_web_object_description, as: :string, label: 'Description'
  filter :abstract_web_object_user_avatar_name, as: :string, label: 'Owner'
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
      link_to donation_box.object_name, admin_donation_box_path(donation_box)
    end
    column 'Description' do |donation_box|
      truncate(donation_box.description, length: 10, separator: ' ')
    end
    column 'Location', sortable: :region, &:slurl
    column 'Server', sortable: 'server.object_name' do |donation_box|
      link_to donation_box.server.object_name,
              admin_server_path(donation_box.server) if donation_box.server
    end
    column 'Owner', sortable: 'users.avatar_name' do |donation_box|
      if donation_box.user
        link_to donation_box.user.avatar_name, admin_user_path(donation_box.user)
      else
        'Orphan'
      end
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
      row :object_name, &:object_name
      row :object_key, &:object_key
      row :description
      row 'Owner', sortable: 'users.avatar_name' do |donation_box|
        if donation_box.user
          link_to donation_box.user.avatar_name, admin_user_path(donation_box.user)
        else
          'Orphan'
        end
      end
      row 'Server' do |donation_box|
        if donation_box.server
          link_to donation_box.server.object_name, admin_server_path(donation_box.server)
        else
          ''
        end
      end
      row :location, &:slurl
      row :total_donations
      row 'Largest Donation' do |db|
        donation = db.largest_donation
        if donation['amount']
          "#{donation['target_name']}: L$ #{donation['amount']} (#{donation['created_at']}})"
        else
          'NA'
        end
      end
      row 'Biggest Donor' do |db|
        donor = db.biggest_donor
        if donor[:amount]
          "#{donor[:avatar_name]}: L$ #{donor[:amount]}"
        else
          'NA'
        end
      end
      row :goal
      row :dead_line
      row :created_at
      row :updated_at
      row :pinged_at
      row :version, &:semantic_version
      row :status, &:pretty_active
    end

    panel 'Top 10 Donors For This Box' do
      counts = resource.transactions.group(:target_name).count
      sums = resource.transactions.group(:target_name).order('sum_amount DESC').sum(:amount)
      data = sums.collect { |k, v| { donor: k, amount: v, count: counts[k] } }
      paginated_data = Kaminari.paginate_array(data).page(params[:donor_page]).per(10)

      table_for paginated_data do
        column :donor
        column :amount
        column('Donations') do |item|
          item[:count]
        end
      end
    end
  end

  sidebar :donations, only: :show do
    paginated_collection(
      resource.transactions.page(
        params[:donation_page]
      ).per(10), param_name: 'donation_page'
    ) do
      table_for collection.order(created_at: :desc).decorate, download_links: false do
        column :created_at
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
        f.input :price
        f.input :quick_pay_1
        f.input :quick_pay_2
        f.input :quick_pay_3
        f.input :quick_pay_4
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
    def scoped_collection
      super.includes(%i[server user transactions])
    end
  end
end
