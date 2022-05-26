# frozen_string_literal: true

module ActiveAdmin
  # Common behavior for Active Admin Rezzable Controllers.
  # Primarily for interacting with in world objecs but could be other things.
  module MessagingBehavior
    extend ActiveSupport::Concern

    def self.included(base)
      base.instance_eval do
        member_action :send_message, method: :post do
          begin
            ServerSlRequest.send_message(
                        current_user.servers.sample.id,
                        params['avatar_name'],
                        params['message'])
            flash.notice = t('active_admin.server.send_message.success', 
                                avatar: params[avatar_name])
          rescue RestClient::ExceptionWithResponse => e
            flash[:error] = t('active_admin.server.send_message.failure',
                            message: e.response)
            redirect_back(fallback_location:
                            send(
                              "#{self.class.module_parent.name.downcase}_dashboard_path"
                            ))
          end
        end
      end
    end
  end
end
