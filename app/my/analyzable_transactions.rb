# frozen_string_literal: true

ActiveAdmin.register Analyzable::Transaction, as: 'Transaction', namespace: :my do
  menu label: 'Transactions', priority: 1

  actions :all, except: %i[destroy]

  config.sort_order = 'created_at_desc'

  scope_to :current_user, association_method: :transactions

  index title: 'Transactions' do
    id_column
    column :created_at
    # column 'Payer/Payee' do |transaction|
    #   avatar = Avatar.find_by_avatar_key(transaction.target_key)
    #   output = if avatar
    #             link_to(transaction.target_name, my_avatar_path(avatar))
    #           else
    #             transaction.target_name
    #           end
    #   output
    # end
    column 'Payer/Paee', &:target_name
    column :amount
    column :previous_balance
    column :balance

    column 'Description' do |transaction|
      truncate(transaction.description, length: 20, separator: ' ')
    end
    column :category
    actions
  end

  filter :target_name, label: 'Avatar Name'
  filter :amount
  filter :created_at
  filter :user_avatar_name, as: :string, Label: 'User Name'
  filter :description
  filter :category, as: :check_boxes, collection: Analyzable::Transaction.categories

  show do
    attributes_table do
      row :amount
      row :previous_balance
      row :balance
      row 'Date', &:created_at
      row 'Date Updated', &:updated_at
      row :description
      row :source_type
      row :category
      row :source_key
      row :source_name
      row 'User' do |transaction|
        link_to transaction.user.avatar_name, my_user_path(transaction.user)
      end
    end
  end

  permit_params :description, :category, :amount, :target_name, :target_key, :source_type

  form do |f|
    f.inputs do
      if f.object.new_record?
        f.input :target_name, label: 'Avatar Name'
        f.input :target_key, label: 'Avatar Key'
        f.input :amount
      end
      f.input :description
      f.input :category
    end
    f.actions
  end

  controller do
    def create
      @transaction = Analyzable::Transaction.new(
        permitted_params[:analyzable_transaction]
      )
      @transaction.source_type = 'Web'
      current_user.transactions << @transaction
      @transaction.save!
      flash.alert = 'A new transaction has been created.'
      redirect_to my_transactions_path
    end

    def handle_avatar; end
  end
end
