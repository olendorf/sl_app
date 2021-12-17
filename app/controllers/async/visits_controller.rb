# frozen_string_literal: true

module Async
  # Handles AJAX requests for data to create charts and tables.
  class VisitsController < AsyncController
    def index
      authorize :async, :index?
      ids = Rezzable::TrafficCop.where(user_id: current_user.id, id: params['ids'])
      render json: send(params['chart'], ids).to_json
    end

    def visits_histogram(ids)
      VisitData.visits_histogram(ids)
    end

    def visitors_time_histogram(ids)
      VisitData.visitors_time_histogram(ids)
    end

    def visitors_counts_histogram(ids)
      Analyzable::Visit.where(web_object_id: ids).group(:avatar_key).count.collect { |_k, v| v }
    end

    def visitors_duration_counts_scatter(ids)
      counts = Analyzable::Visit.where(web_object_id: ids).group(:avatar_name).count
      durations = Analyzable::Visit.where(web_object_id: ids).group(:avatar_name).sum(:duration)
      counts.collect { |k, v| { x: v, y: durations[k] / 60.0, name: k } }
    end

    # rubocop:disable Metrics/AbcSize
    def visits_timeline(ids)
      VisitData.visits_timeline(ids)
    end
    # rubocop:enable Metrics/AbcSize

    def visits_heatmap(ids)
      VisitData.visits_heatmap(ids)
    end

    def duration_heatmap(ids)
      VisitData.duration_heatmap(ids)
    end

    # rubocop:disable Metrics/AbcSize
    def visit_location_heatmap(ids)
      VisitData.visit_location_heatmap(ids)
    end
    # rubocop:enable Metrics/AbcSize
  end
end
