# frozen_string_literal: true

ActiveAdmin.register Analyzable::Parcel, as: 'Parcel', namespace: :my do
  menu label: 'Parcels', if: proc { current_user.parcels.size.positive? }

  decorate_with Analyzable::ParcelDecorator

  scope_to :current_user, association_method: :parcels

  actions :all, except: %i[new create]

  index title: 'Parcels' do
    selectable_column
    column 'Parcel Name' do |parcel|
      link_to parcel.parcel_name, my_parcel_path(parcel)
    end
    column 'Description' do |parcel|
      truncate(parcel.description, length: 20, separator: ' ')
    end
    column 'State' do |parcel|
      parcel.current_state.humanize
    end
    column 'Current Renter', &:owner_name
    column :expiration_date
    column :area
    column :weekly_tier
    column :purchase_price
    column 'Location', &:slurl

    actions
  end

  filter :parcel_name
  filter :description
  filter :owner_name, label: 'Renter Name'
  filter :area
  filter :region
  filter :weekly_tier
  filter :expiration_date
  filter :current_state, as: :check_boxes,
                         collection: Analyzable::RentalState
                           .states.keys.collect { |k| [k.humanize, k] }

  show title: :parcel_name do
    attributes_table do
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
      row 'Location', &:slurl
    end

    panel 'Activity' do
      paginated_collection(
        resource.states.order(created_at: :desc).page(
          params[:state_page]
        ).per(10), param_name: 'state_page', download_links: false
      ) do
        table_for collection do
          column 'Event', &:state
          column 'Start', &:created_at
          column 'End', &:closed_at
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
