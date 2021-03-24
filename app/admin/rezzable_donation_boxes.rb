ActiveAdmin.register Rezzable::DonationBox, as: 'Donation Box' do
  
  include ActiveAdmin::RezzableBehavior
  
  menu label: 'Donation Boxes'
  
  actions :all, except: %i[new create]
  
  decorate_with Rezzable::DonationBoxDecorator
  
  filter :abstract_web_object_object_name, as: :string, label: 'Object Name'
  
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
    column :sttus, &:pretty_active

    column :created_at, sortable: :created_at
    actions
  end
  
  sidebar :settings do 
    attributes_table do 
      row :show_last_donation
      row :show_last_donor
      row :show_total
      row :show_largest_donation
      row :show_biggest_donor
    end
  end
    
  show title: :object_name do
    attributes_table do
      row :server_name, &:object_name
      row :server_key, &:object_key
      row :description
      row 'Owner', sortable: 'users.avatar_name' do |server|
        if server.user
          link_to server.user.avatar_name, admin_user_path(server.user)
        else
          'Orphan'
        end
      end
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
