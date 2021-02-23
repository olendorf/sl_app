ActiveAdmin.register Rezzable::Server do

  menu label: 'Servers'

  actions :all, except: %i[new create]

  decorate_with Rezzable::ServerDecorator
  
  index title: 'Servers' do
    selectable_column
    column 'Object Name', sortable: :object_name do |terminal|
      link_to terminal.object_name, admin_rezzable_terminal_path(terminal)
    end
    column 'Description' do |terminal|
      truncate(terminal.description, length: 10, separator: ' ')
    end
    column 'Clients' do |server|
      server.clients.count
    end
    column 'Location', sortable: :region, &:slurl
    column 'Owner', sortable: 'users.avatar_name' do |terminal|
      if terminal.user
        link_to terminal.user.avatar_name, admin_user_path(terminal.user)
      else
        'Orphan'
      end
    end
    # column 'Last Ping', sortable: :pinged_at do |terminal|
    #   if terminal.active?
    #     status_tag 'active', label: time_ago_in_words(terminal.pinged_at)
    #   else
    #     status_tag 'inactive', label: time_ago_in_words(terminal.pinged_at)
    #   end
    # end
    column :created_at, sortable: :created_at
    actions
  end
  
  filter :abstract_web_object_object_name, as: :string, label: 'Object Name'
  filter :abstract_web_object_description, as: :string, label: 'Description'
  filter :abstract_web_object_user_avatar_name, as: :string, label: 'Owner'
  filter :abstract_web_object_region, as: :string, label: 'Region'
  # filter :web_object_pinged_at, as: :date_range, label: 'Last Ping'
  filter :abstract_web_object_create_at, as: :date_range
  
  show title: :object_name do
    attributes_table do
      row :object_name do |server|
        link_to server.user.avatar_name, admin_user_path(server.user)
      end
      row :object_key
      row :description
      row 'Owner', sortable: 'users.avatar_name' do |server|
        if server.user
          link_to server.user.avatar_name, admin_user_path(server.user)
        else
          'Orphan'
        end
      end
      row :location, &:slurl
      row :created_at
      row :updated_at
      row :pinged_at
      # row :version, &:semantic_version
      # row :status do |terminal|
      #   if terminal.active?
      #     status_tag 'active', label: 'Active'
      #   else
      #     status_tag 'inactive', label: 'Inactive'
      #   end
      # end
    end
    
    panel 'Clients' do 
      paginated_collection(
        resource.clients.page(
          params[:client_page]
          ).per(20), param_name: 'client_page'
      ) do 
        table_for collection.decorate do
          column 'Object Name' do |client|
            path = "admin_#{client.model.actable.model_name.route_key.singularize}_path"
            link_to client.object_name, send(path, client.model.actable.id)
          end
          column 'Temp' do |client|
            client.model.actable.class.name.split('::').last
          end
          column :location, &:slurl
        end
      end
    end
  end

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :object_name, :object_key, :description, :region, :position, :url, :api_key, :user_id, :pinged_at, :major_version, :minor_version, :patch_version, :server_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:object_name, :object_key, :description, :region, :position, :url, :api_key, :user_id, :pinged_at, :major_version, :minor_version, :patch_version, :server_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
