# frozen_string_literal: true

ActiveAdmin.register Split, namespace: :my do
  menu false

  actions :destroy

  scope_to :current_user, association_method: :splits

  controller do
    def destroy
      split = Split.find(params['id'])
      split.destroy!
      flash.notice = I18n.t('active_admin.batch_actions.succesfully_destroyed.one', model: 'Split')
      redirect_back(fallback_location: my_dashboard_path)
    end
  end
end
