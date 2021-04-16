# frozen_string_literal: true

ActiveAdmin.register ListableAvatar do
  menu false
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :avatar_name, :avatar_key, :list_name, :listable_id, :listable_type
  #
  # or
  #
  # permit_params do
  #   permitted = [:avatar_name, :avatar_key, :list_name, :listable_id, :listable_type]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  permit_params :avatar_name, :avatar_key, :list_name, :listable_id, :listable_type

  controller do
    def scoped_collection
      super.includes(:listable)
    end

    def create
      permitted = params.require(:listable_avatar).permit(:avatar_name, :avatar_key, :list_name,
                                                          :listable_id, :listable_type)
      avatar = ListableAvatar.create(permitted)

      flash.notice = I18n.t('active_admin.listable_avatar.create.success',
                            avatar_name: avatar.avatar_name,
                            list_name: avatar.list_name.humanize.downcase)
      redirect_back(fallback_location: admin_dashboard_path)
    end

    def destroy
      avatar = ListableAvatar.find(params['id'])
      avatar.destroy!
      flash.notice = I18n.t('active_admin.listable_avatar.destroy.success',
                            avatar_name: avatar.avatar_name,
                            list_name: avatar.list_name.humanize.downcase)
      redirect_back(fallback_location: admin_dashboard_path)
    end
  end
end
