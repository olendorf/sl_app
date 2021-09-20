# frozen_string_literal: true

ActiveAdmin.register Analyzable::Parcel, as: 'Parcel' do

  menu label: 'Parcels'

  decorate_with Analyzable::ParcelDecorator

  actions :all, except: %i[new create]
  
  index title: 'Parcels' do
    selectable_column
    column 'Owner' do |parcel|
      link_to parcel.user.avatar_name, admin_user_path(parcel.user)
    end
    column 'Parcel Name' do |parcel|
      link_to parcel.parcel_name, admin_parcel_path(parcel)
    end
    column 'Description' do |parcel|
      truncate(parcel.description, length: 20, separator: ' ')
    end
    column 'State' do |parcel|
      parcel.states.last.state.humanize
    end
    column 'Current Renter' do |parcel|
      parcel.owner_name
    end
    column :expiration_date
    column :area
    column :weekly_tier
    column :purchase_price
    column 'Location' do |parcel|
      parcel.slurl
    end
    
    actions
  end
  
  filter :parcel_name
  filter :description
  filter :owner_name, label: 'Renter Name'
  filter :area
  filter :region
  filter :weekly_tier
  filter :expiration_date
  filter :user_avatar_name, as: :string, label: 'Owner Name'
  
  show title: :parcel_name do 
    attributes_table do 
      row 'Owner' do |parcel|
        link_to parcel.user.avatar_name, admin_user_path(parcel.user)
      end
      row :description
      row 'State' do |parcel|
        parcel.states.last.state.humanize
      end
      row 'Current Renter' do |parcel|
        parcel.owner_name.nil? ? 'Empty' : parcel.owner_name
      end
      row :expiration_date
      row :area
      row :weekly_tier
      row :purchase_price
      row 'Location' do |parcel|
        parcel.slurl
      end
    end
    
    panel 'Activity' do 
      paginated_collection(
        resource.states.order(created_at: :desc).page(
          params[:state_page]
        ).per(10), param_name: 'state_page', download_links: false
      ) do 
        table_for collection do 
          column 'Event' do |state|
            state.state 
          end
          column 'Start' do |state|
            state.created_at
          end
          column 'End' do |state|
            state.closed_at
          end 
          column 'Duration' do |state|
            distance_of_time_in_words(state.duration)
          end
          
        end
      end
    end
    
    
  end

  permit_params :parcel_name, :description, :expiration_date, :area, :weekly_tier, :purchase_price
  
  form title: proc { "Edit parcel #{resource.parcel_name}" } do |f|
    f.inputs do 
      f.input :parcel_name
      f.input :description
      f.input :expiration_date, as: :datetime_picker
      f.input :area
      f.input :weekly_tier
      f.input :purchase_price
    end
    f.actions
  end
  
  controller do
    def scoped_collection
      super.includes(%i[user])
    end
  end
end
