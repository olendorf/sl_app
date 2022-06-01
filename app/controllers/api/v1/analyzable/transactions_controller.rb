class Api::V1::Analyzable::TransactionsController < Api::V1::AnalyzableController
    
  def create
    authorize [:api, :v1, @requesting_object]
    @requesting_object.user.transactions << Analyzable::Transaction.new(atts)
    render json: { message: 'Created'}, status: 201
  end
end
