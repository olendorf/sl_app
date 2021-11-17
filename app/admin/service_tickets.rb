# frozen_string_literal: true

ActiveAdmin.register ServiceTicket do
  scope('Open', default: true) do |scope|
    scope.where(status: 'open').order(:created_at).reverse_order
  end
  scope :all

  actions :all, except: %i[destroy]

  batch_action :close do |ids|
    batch_action_collection.find(ids).each do |ticket|
      ticket.update(status: 'closed')
    end
    redirect_to collection_path, alert: 'The tickets have been closed.'
  end

  index do
    selectable_column
    column('Title') do |ticket|
      link_to ticket.title, admin_service_ticket_path(ticket)
    end
    column 'Description' do |ticket|
      ticket.description.truncate(48, separator: ' ')
    end
    column :client_name
    column :status
    column('Date Started') do |ticket|
      ticket.created_at.to_formatted_s(:long)
    end
    column('Last Action') do |ticket|
      ticket.updated_at.to_formatted_s(:long)
    end
    actions default: true do |ticket|
      link_to 'Close', close_admin_service_ticket_path(ticket), method: :put
    end
  end

  filter :title
  filter :description
  filter :client_name
  filter :created_at, lable: 'Date Started'
  filter :updated_at, label: 'Last Action'

  show title: :title do
    attributes_table do
      row :description
      row :client_name
      row :status
      row 'Date Started', &:created_at
      row 'Last Action', &:updated_at
    end

    panel 'Comments' do
      table_for resource.comments do
        column 'Date Time', &:created_at
        column 'Avatar Name', &:author
        column '', &:text
      end

      # div do
      #   render 'service_ticket_comment_form', author: current_user.avatar_name

      # end
    end
  end

  permit_params :title, :description, :status, comments_attributes: %i[id author text]

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :title, :description, :client_key, :user_id, :status, :client_name
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :description, :client_key, :user_id, :status, :client_name]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  form title: proc { "Edit #{resource.title}" } do |f|
    f.inputs do
      f.input :title
      f.input :description
      f.input :status
      f.inputs do
        f.has_many :comments, heading: 'Comments',
                              new_record: true do |c|
          c.input :author, as: :hidden, input_html: { value: current_user.avatar_name }
          c.input :text, as: :text
        end
      end
    end
    f.actions
  end

  member_action :close, method: :put do
    resource.close!
    redirect_to admin_service_tickets_path, notice: 'This ticket was closed.'
  end
end
