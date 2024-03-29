# frozen_string_literal: true

module Api
  module V1
    # Parent controll for all rezzable objects
    class AbstractWebObjectsController < Api::V1::ApiController
      before_action :process_atts, only: %i[create update]

      def create
        if AbstractWebObject.find_by_object_key(@atts[:object_key])
          load_requesting_object
          update
        else
          authorize [:api, :v1, requesting_class]
          @web_object = requesting_class.new(@atts)
          @web_object.save!
          render json: {
            message: I18n.t('api.rezzable.create.success'),
            data: @web_object.response_data
          }, status: :created
        end
      end

      def update
        load_requesting_object
        authorize [:api, :v1, @requesting_object]
        
        logger.info "attributes: #{@atts}"

        @requesting_object.update! @atts.with_indifferent_access

        render json: {
          message: I18n.t('api.rezzable.update.success'),
          data: @requesting_object.response_data
        }, status: :ok
      end

      def show
        authorize [:api, :v1, @requesting_object]
        render json: {
          data: @requesting_object.response_data
        }
      end

      def destroy
        authorize [:api, :v1, @requesting_object]
        @requesting_object.destroy!
        render json: {
          message: I18n.t('api.rezzable.destroy.success')
        }, status: :ok
      end

      private

      def requesting_class
        "::Rezzable::#{controller_name.classify}".constantize
      end

      def process_atts
        @atts = {
          object_key: request.headers['HTTP_X_SECONDLIFE_OBJECT_KEY'],
          object_name: request.headers['HTTP_X_SECONDLIFE_OBJECT_NAME'],
          region: extract_region_name,
          position: format_position,
          user_id: User.find_by_avatar_key!(
            request.headers['HTTP_X_SECONDLIFE_OWNER_KEY']
          ).id
        }.merge(JSON.parse(request.raw_post))
      end

      def extract_region_name
        region_regex = /(?<name>[a-zA-Z0-9 ]+) ?\(?/
        matches = request.headers['HTTP_X_SECONDLIFE_REGION'].match(region_regex)
        matches[:name]
      end

      def format_position
        pos_regex = /\((?<x>[0-9.]+), (?<y>[0-9.]+), (?<z>[0-9.]+)\)/
        matches = request.headers['HTTP_X_SECONDLIFE_LOCAL_POSITION'].match(pos_regex)
        { x: matches[:x].to_f, y: matches[:y].to_f, z: matches[:z].to_f }.to_json
      end
    end
  end
end
