class Api::V1::ServiceTicketsController < Api::V1::AnalyzableController
  def index 
    authorize @requesting_object
    data = @requesting_object.user.service_tickets.
                      where(status: 'open', client_key: params['avatar_key']).
                        collect{ |ticket| {id: ticket.id, title: ticket.title[0..12]} }
    render json: {message: 'OK', data: data}, status: :ok
  end
  
  def create 
    authorize @requesting_object
    ticket = ServiceTicket.new(
      title: params['title'],
      description: params['description'],
      client_key: params['client_key'],
      client_name: params['client_name'],
      )
    @requesting_object.user.service_tickets << ticket
    render json: {message: 'Your service ticket has been created.'}, status: :created
  end
  
  def show
    authorize @requesting_object
    ticket = ServiceTicket.where(
        client_key: params['avatar_key'], 
        id: params['id']
      ).first
    message = "Date Started: #{ticket.created_at.to_formatted_s(:long)}\n" + 
              "Title: #{ticket.title}\n" + 
              "Status #{ticket.status}\n" +
              "==========================================================\n" + 
              ticket.description
    ticket.comments.each do |comment|
      message += "\n\n ==================================================\n\n" +
                 "Author: #{comment.author}\n" + 
                 "Comment Date: #{comment.created_at.to_formatted_s(:long)}\n\n" +
                 "#{comment.text}."
    end
    
    render json: {message: message}, status: :ok
  end
  
  # The only update that should happen here is to add a comment or close a ticket
  def update
    authorize @requesting_object
    ticket = ServiceTicket.where(
        client_key: params['avatar_key'], 
        id: params['id']
      ).first
    if(params['comment_text'])
      ticket.comments << Comment.new(author: params['avatar_name'], text: params['comment_text'])
    end 
    if(params['status'])
      ticket.update(status: params['status'])
    end
    render json: {message: 'OK'}, status: :ok
  end
end
