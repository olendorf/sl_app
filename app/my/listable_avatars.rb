# frozen_string_literal: true

ActiveAdmin.register ListableAvatar, namespace: :my do
  menu false

  actions :all, except: %I[index show new update edit]

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
