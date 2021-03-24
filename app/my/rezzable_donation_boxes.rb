ActiveAdmin.register Rezzable::DonationBox, namespace: :my, as: 'Donation Box' do
  
  include ActiveAdmin::RezzableBehavior
  
  menu label: 'Donation Boxes'
  
  actions :all, except: %i[new create]
  
  decorate_with Rezzable::DonationBoxDecorator
  
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
      link_to donation_box.object_name, admin_donation_box_path(donation_box)
    end
    column 'Description' do |donation_box|
      truncate(donation_box.description, length: 10, separator: ' ')
    end
    column 'Location', sortable: :region, &:slurl
    column 'Server', sortable: 'server.object_name' do |donation_box|
      link_to donation_box.server.object_name, admin_server_path(donation_box.server) if donation_box.server
    end
    column 'Total Donations', &:total_donations
    column :goal
    column :dead_line
    column 'Version', &:semantic_version
    column :sttus, &:pretty_active

    column :created_at, sortable: :created_at
    actions
  end
  
  sidebar :settings, only: [:edit, :show] do 
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
      row :server_name, &:object_name
      row :server_key, &:object_key
      row :description
      row :location, &:slurl
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
    
    panel 'Donations' do 
      paginated_collection(
        resource.transactions.page(
          params[:donation_page]
          ).per(20), param_name: 'donation_page'
        ) do 
          table_for collection.order(created_at: :desc).decorate do 
            column :created_at
            column 'Payer/Payee' do |donation|
              avatar = Avatar.find_by_avatar_key(donation.target_key)
              output = if avatar
                         link_to(donation.target_name, admin_avatar_path(avatar))
                       else
                         donation.target_name
                       end
              output
            end
            column :amount
            column 'Description' do |donation|
              truncate(donation.description, length: 20, separator: ' ')
            end
          end
        end
    end
  end
  
  permit_params :object_name, :description, :show_last_donation, :show_last_donor, 
                :show_total, :show_largest_donation, :show_biggest_donor, :goal, 
                :dead_line, :response, :server_id

  form title: proc { "Edit #{resource.object_name}" } do |f|
    f.inputs do 
      if resource.user
        f.input :object_name, label: 'Donation Box Name'
        f.input :description
        f.input :server_id, as: :select, collection: resource.user.servers.map{ |s|
          [s.object_name, s.actable.id]
        }
        f.input :show_largest_donation
        f.input :show_last_donor
        f.input :show_total
        f.input :show_largest_donation
        f.input :goal, :as => :number, 
                       :input_html => { 
                          :min => 0,
                          :step => 1}
        f.input :dead_line, as: :datetime_picker
        f.input :response
      end
      f.actions
    end
  end
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :object_name, :object_key, :description, :region, :position, :url, :api_key, :user_id, :pinged_at, :major_version, :minor_version, :patch_version, :server_id, :show_last_donation, :show_last_donor, :show_total, :show_largest_donation, :show_biggest_donor, :total, :goal, :dead_line, :response
  #
  # or
  #
  # permit_params do
  #   permitted = [:object_name, :object_key, :description, :region, :position, :url, :api_key, :user_id, :pinged_at, :major_version, :minor_version, :patch_version, :server_id, :show_last_donation, :show_last_donor, :show_total, :show_largest_donation, :show_biggest_donor, :total, :goal, :dead_line, :response]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
  controller do
    def scoped_collection
      super.includes([:server, :user, :transactions])
    end
  end
  
end
