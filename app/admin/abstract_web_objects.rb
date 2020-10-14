ActiveAdmin.register AbstractWebObject do
  
  menu label: 'Rezzed Objects'
  
  breadcrumb do
    links = [link_to('Admin', admin_root_path), link_to('Rezzed Objects', admin_abstract_web_objects_path)]
    if %(show edit).include?(params['action'])
      links << link_to(resource.object_name, admin_abstract_web_object_path)
    end
    links
  end
  
  
  
  actions :all, except: [:new, :create]
  
  decorate_with AbstractWebObjectDecorator

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :object_name, :description
  #
  # or
  #
  # permit_params do
  #   permitted = [:object_name, :object_key, :description, :region, :position, :url, :api_key, :user_id, :actable_id, :actable_type, :pinged_at, :major_version, :minor_version, :patch_version]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
  index title: 'Rezzed Objects' do 
    selectable_column
    column :object_name
    column 'Description', sortable: :sortable do |web_object|
      web_object.description.truncate(20, separator: ' ')
    end
    column 'Location', sortable: :region do |web_object| 
      web_object.slurl
    end
    column 'Owner', sortable: 'users.avatar_name' do |web_object|
      if web_object.user
        link_to web_object.user.avatar_name, admin_user_path(web_object.user)
      else
        'Orphan'
      end
    end
    column :actable_type
    column :pinged_at
    column :created_at
    actions
  end
  
  filter :object_name
  filter :region
  filter :user_avatar_name, as: :string
  filter :actable_type
  filter :pinged_at
  filter :created_at
  
  show title: :object_name do
    attributes_table do
      row :object_name
      row :description
      row 'Location' do |web_object|
        web_object.slurl
      end
      row 'Owner' do |web_object|
        if web_object.user
          link_to web_object.user.avatar_name, admin_user_path(web_object.user)
        else
          'Orphan'
        end
      end
      row :actable_type
      row :pinged_at
      row :major_version
      row :minor_version
      row :patch_version
      row :created_at
      row :updated_at
    end
  end
  
  form title: proc { "Edit #{resource.object_name}" } do |f|
    f.inputs do
      f.input :object_name
      f.input :description
    end 
    f.actions
  end
  
end
