class Async::VisitsController < ApplicationController
  def index 
    authorize :async, :index?
    ids = Rezzable::TrafficCop.where(user_id: current_user.id, id: params['ids'])
    render json: send(params['chart'], ids).to_json
  end
  
  def visits_histogram(ids) 
    Analyzable::Visit.select(:duration).where(web_object_id: ids).collect { |v| v.duration/60.0 }.compact
  end
  
  def visitors_time_histogram(ids)
    Analyzable::Visit.where(web_object_id: ids).group(:avatar_key).sum(:duration).collect{ |k, v| v/60.0 }
  end
  
  def visitors_counts_histogram(ids)
    Analyzable::Visit.where(web_object_id: ids).group(:avatar_key).count.collect{ |k, v| v }
  end
  
  def visitors_duration_counts_scatter(ids) 
    counts = Analyzable::Visit.where(web_object_id: ids).group(:avatar_name).count
    durations = Analyzable::Visit.where(web_object_id: ids).group(:avatar_name).sum(:duration)
    counts.collect { |k, v| {x: v, y: durations[k]/60.0, name: k} }
  end
  
  def visits_timeline(ids)
    visits = Analyzable::Visit.where(web_object_id: ids).order(:start_time)
    dates = time_series_dates(visits.first.start_time - 3.days, Time.current)
    visitor_data = visits.collect do |d| 
      {date: d.start_time.strftime('%F'), 
       avatar_name: d.avatar_name} 
    end.group_by { |h| h[:date] }
    counts = Array.new(dates.size, 0)
    durations = Array.new(dates.size, 0)
    visitors = Array.new(dates.size, 0)
    visits.each do |v| 
      index = dates.index(v.start_time.strftime('%F'))
      counts[index] += 1
      durations[index] += v.duration
      visitors[index] = visitor_data[v.start_time.strftime('%F')].size
    end
    data = {dates: dates, counts: counts, durations: durations, visitors: visitors}
    data
    
  end
  
  def visits_heatmap(ids)
    visits = Analyzable::Visit.where(web_object_id: ids).order(:start_time)
    data = []
    (0..23).each { |h| (0..6).each { |d| data << [d, h, 0] } }
    visits.each do |visit|
      h = visit.start_time.strftime('%k').to_i
      d = visit.start_time.strftime('%w').to_i
      data[(d * 24) + h][2] = data[(d * 24) + h][2] + 1
    end
    data
  end
  
    
  def duration_heatmap(ids)
    visits = Analyzable::Visit.where(web_object_id: ids).order(:start_time)
    data = []
    (0..6).each { |d| (0..23).each { |h| data << [d, h, 0] } }
    visits.each do |visit|
      h = visit.start_time.strftime('%k').to_i
      d = visit.start_time.strftime('%w').to_i
      data[(d * 24) + h][2] = data[(d * 24) + h][2] + visit.duration/60.0
    end
    data
  end
  
  def visit_location_heatmap(ids)
    visits = Analyzable::Visit.includes(:detections).where(web_object_id: ids)
    data = []
    256.times { |x| 256.times { |y| data << [x, y, 0] } }
    visits.each do |visit|
      visit.detections.each do |det|
        pos = JSON.parse(det.position).map { |k, v| [k, v.floor] }.to_h
        pos['x'] = 255 if pos['x'] > 255
        pos['y'] = 255 if pos['y'] > 255
        data[256 * pos['x'] + pos['y']][2] += 0.5
      end 
    end
    { data: data, max: data.collect{ |d| d[2] }.max }
  end
  
  def time_series_dates(start, stop, interval = 1.day)
    dates = []
    step_time = start
    
    while step_time <= stop do
      dates << step_time.strftime('%F')
      step_time += interval
    end
    dates
    
  end
end
