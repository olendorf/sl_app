class Async::DonationsController < AsyncController
  
  def index 
    authorize :async, :index?
    render json:  send(params['chart']).to_json 
  end
  
  
  private
  
  def donation_histogram
    ids = current_user.donation_boxes.collect { |box| box.abstract_web_object.id }
    current_user.transactions.where(web_object_id: ids).collect { |d| d.amount }
  end
  
  def donor_amount_histogram
    ids = current_user.donation_boxes.collect { |box| box.abstract_web_object.id }
    current_user.transactions.where(web_object_id: ids).
      group(:target_name).sum(:amount).collect { |k, v| v }
  end
end 