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
