class Async::DonationsController < AsyncController
  
  def index 
    authorize :async, :index?
    render json:  send(params['chart']).to_json 
  end
  
  
  private
  
  def donation_histogram
    current_user.donations.collect { |d| d.amount }
  end
  
  def donor_amount_histogram
    current_user.donations.group(:target_name).sum(:amount).collect { |k, v| v }
  end
  
  def donor_scatter_plot
    amounts = current_user.donations.group(:target_name).sum(:amount).sort_by {|_key, value| -value}.to_h
    counts = current_user.donations.group(:target_name).count
    
    data = amounts.collect { |k, v| {key: k, x: counts[k], y: v } }   
    puts data.to_json
    data
  end
end 