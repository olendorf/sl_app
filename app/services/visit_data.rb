# frozen_string_literal: true

# Handles data processing for parcels
class VisitData
  include DataHelper

  def self.visits_histogram(ids)
    Analyzable::Visit.select(:duration).where(web_object_id: ids).collect do |v|
      v.duration / 60.0
    end.compact
  end

  def self.visitors_time_histogram(ids)
    Analyzable::Visit.where(web_object_id: ids)
                     .group(:avatar_key).sum(:duration).collect do |_k, v|
      v / 60.0
    end
  end

  def self.visits_timeline(ids)
    visits = Analyzable::Visit.where(web_object_id: ids).order(:start_time)
    dates = time_series_dates(visits.first.start_time - 3.days, Time.current + 1.day)
    visitor_data = visits.collect do |d|
      { date: d.start_time.strftime('%F'),
        avatar_name: d.avatar_name }
    end
    visitor_data = visitor_data.group_by { |h| h[:date] }
    counts = Array.new(dates.size, 0)
    durations = Array.new(dates.size, 0)
    visitors = Array.new(dates.size, 0)
    visits.each do |v|
      index = dates.index(v.start_time.strftime('%F'))
      counts[index] += 1 unless counts[index].nil?
      durations[index] += v.duration.to_f/60.0
      visitors[index] = visitor_data[v.start_time.strftime('%F')].uniq.size
    end
    { dates: dates, counts: counts, durations: durations, visitors: visitors }
  end

  def self.visits_heatmap(ids)
    visits = Analyzable::Visit.where(web_object_id: ids).order(:start_time)
    data = []
    (0..6).each { |d| (0..23).each { |h| data << [d, h, 0] } }
    visits.each do |visit|
      h = visit.start_time.strftime('%k').to_i
      d = visit.start_time.strftime('%w').to_i
      data[(d * 24) + h][2] = data[(d * 24) + h][2] + 1
    end
    data
  end

  def self.duration_heatmap(ids)
    visits = Analyzable::Visit.where(web_object_id: ids).order(:start_time)
    data = []
    (0..6).each { |d| (0..23).each { |h| data << [d, h, 0] } }
    visits.each do |visit|
      h = visit.start_time.strftime('%k').to_i
      d = visit.start_time.strftime('%w').to_i
      data[(d * 24) + h][2] = data[(d * 24) + h][2] + (visit.duration / 60.0)
    end
    data
  end

  def self.visit_location_heatmap(ids)
    visits = Analyzable::Visit.includes(:detections).where(web_object_id: ids)
    data = []
    256.times { |x| 256.times { |y| data << [x, y, 0] } }
    visits.each do |visit|
      visit.detections.each do |det|
        pos = JSON.parse(det.position).transform_values(&:floor)
        pos['x'] = 255 if pos['x'] > 255
        pos['y'] = 255 if pos['y'] > 255
        data[(256 * pos['x']) + pos['y']][2] += 0.5
      end
    end
    { data: data, max: data.collect { |d| d[2] }.max }
  end
end
