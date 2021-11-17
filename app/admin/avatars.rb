# frozen_string_literal: true

ActiveAdmin.register Avatar do
  actions :show, :index, :destroy

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :avatar_key, :avatar_name, :display_name, :rezday
  #
  # or
  #
  # permit_params do
  #   permitted = [:avatar_key, :avatar_name, :display_name, :rezday]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
end
