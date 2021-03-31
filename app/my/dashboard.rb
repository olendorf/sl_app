# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard', namespace: :my do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    div class: 'blank_slate_container', id: 'dashboard_default_message' do
      span class: 'blank_slate' do
        span I18n.t('active_admin.dashboard_welcome.welcome')
        small I18n.t('active_admin.dashboard_welcome.call_to_action')
      end
    end
    
    ids = current_user.donation_boxes.collect { |db| db.abstract_web_object.id }
    @data = current_user.transactions.where(web_object_id: ids).
        group(:target_name).sum(:amount).collect { |k, v| v }
    render partial: 'dashboard_test', locals: {amounts: @data}

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end

  sidebar :splits, only: %i[index] do
    total = 0
    dl class: 'row' do
      current_user.splits.each do |split|
        total += split.percent
        dt split.target_name
        dd "#{split.percent}%"
      end
      dt 'Total'
      dd "#{total}%"
    end

    hr
    link_to 'Edit Splits', edit_my_user_path(current_user)
  end
end
