# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Async::Visits', type: :request do
  describe 'GET' do
    before(:all) do
      @user = FactoryBot.create :active_user
      @traffic_cop = FactoryBot.create :traffic_cop, user_id: @user.id
      @avatars = FactoryBot.create_list(:avatar, 20)
      20.times do
        visitor = @avatars.sample
        visit = FactoryBot.create(:visit, avatar_name: visitor.avatar_name,
                                          avatar_key: visitor.avatar_key,
                                          web_object_id: @traffic_cop.id)
        visit.detections << FactoryBot.build(:detection)
        20.times do
          position = JSON.parse(visit.detections.last.position)
          position['x'] += rand(-5.0..5.0)
          position['y'] += rand(-5.0..5.0)
          position['z'] += rand(-5.0..5.0)
          FactoryBot.create(:detection, visit_id: visit.id, position: position.to_json)
          visit.stop_time = visit.stop_time + 30.seconds
          visit.duration = visit.duration + 30.seconds
          visit.save
        end
      end
    end

    let(:path) { async_visits_path }

    before(:each) { sign_in @user }

    context 'asking for data from a single traffic_cop' do
      describe 'visits histogram data' do
        it 'should return ok status' do
          get path, params: { chart: 'visits_histogram', ids: @traffic_cop.id }
          expect(response.status).to eq 200
        end

        it 'should return the data' do
          get path, params: { chart: 'visits_histogram', ids: @traffic_cop.id }
          expect(JSON.parse(response.body).size).to eq @traffic_cop.visits.size
        end
      end

      describe 'visitor duraation data' do
        it 'should return ok status' do
          get path, params: { chart: 'visitors_time_histogram', ids: @traffic_cop.id }
          expect(response.status).to eq 200
        end

        it 'should return the data' do
          get path, params: { chart: 'visitors_time_histogram', ids: @traffic_cop.id }
          expect(JSON.parse(response.body).size).to be_between(1, 20)
        end
      end

      describe 'visitor counts data' do
        it 'should return ok status' do
          get path, params: { chart: 'visitors_counts_histogram', ids: @traffic_cop.id }
          expect(response.status).to eq 200
        end

        it 'should return the data' do
          get path, params: { chart: 'visitors_counts_histogram', ids: @traffic_cop.id }
          expect(JSON.parse(response.body).size).to be_between(1, 20)
        end
      end

      describe 'visitor duration counts scatter data' do
        it 'should return ok status' do
          get path, params: { chart: 'visitors_duration_counts_scatter', ids: @traffic_cop.id }
          expect(response.status).to eq 200
        end

        it 'should return the data' do
          get path, params: { chart: 'visitors_duration_counts_scatter', ids: @traffic_cop.id }
          expect(JSON.parse(response.body).size).to be_between(1, 20)
        end
      end

      describe 'visit counts timeline data' do
        it 'should return ok status' do
          get path, params: { chart: 'visits_timeline', ids: @traffic_cop.id }
          expect(response.status).to eq 200
        end

        it 'should return the correct data' do
          get path, params: { chart: 'visits_timeline', ids: @traffic_cop.id }
          expect(JSON.parse(response.body)['counts']).to eq  [0, 0, 0, 20]
          expect(JSON.parse(response.body)['durations']).to eq [0, 0, 0, 205.0]
          expect(JSON.parse(response.body)).to include 'counts', 'durations', 'visitors', 'dates'
        end
      end

      describe 'visit heatmap data' do
        it 'should return ok status' do
          get path, params: { chart: 'visits_heatmap', ids: @traffic_cop.id }
          expect(response.status).to eq 200
        end

        it 'should return the correct data' do
          get path, params: { chart: 'visits_heatmap', ids: @traffic_cop.id }
          expect(JSON.parse(response.body).collect { |d| d[2] }.max).to eq 20
        end
      end
      describe 'duration heatmap data' do
        it 'should return ok status' do
          get path, params: { chart: 'duration_heatmap', ids: @traffic_cop.id }
          expect(response.status).to eq 200
        end

        it 'should return the correct data' do
          get path, params: { chart: 'duration_heatmap', ids: @traffic_cop.id }
          expect(JSON.parse(response.body).collect { |d| d[2] }.max).to eq 205.0
        end
      end

      describe 'visit_location_heatmap' do
        it 'should return ok status' do
          get path, params: { chart: 'visit_location_heatmap', ids: @traffic_cop.id }
          expect(response.status).to eq 200
        end

        it 'should return the correct data' do
          get path, params: { chart: 'visit_location_heatmap', ids: @traffic_cop.id }

          expect(JSON.parse(response.body)['data'].collect { |d| d[2] }.max).to be >= 1
        end
      end

      # describe 'visit time spent timeline data' do
      #   it 'should return ok status' do
      #     get path, params: { chart: 'visits_time_spent_timeline', ids: @traffic_cop.id }
      #     expect(response.status).to eq 200
      #   end

      #   it 'should return the correct data' do
      #     get path, params: { chart: 'visits_time_spent_timeline', ids: @traffic_cop.id }
      #     expect(JSON.parse(response.body)[Time.current.strftime('%F')]).to eq 300
      #   end
      # end
    end
  end
end
