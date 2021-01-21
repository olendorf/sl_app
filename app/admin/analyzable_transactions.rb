# frozen_string_literal: true

ActiveAdmin.register Analyzable::Transaction do
  menu label: 'Transactions'

  actions :all

  config.sort_order = 'created_at_desc'

  index title: 'Transactions' do
    selectable_column
    column :created_at
    column 'Payer/Payee', :target_name
    column :amount
    column :previous_balance
    column :balance
    column 'User' do |transaction|
      link_to transaction.user.avatar_name, admin_user_path(transaction.user)
    end
    column 'Description' do |transaction|
      truncate(transaction.description, length: 20, separator: ' ')
    end
    column :category
    actions
  end

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
        link_to transaction.user.avatar_name, admin_user_path(transaction.user)
      end
    end
  end

  permit_params :description, :category, :amount, :target_name, :target_key

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
      current_user.transactions << @transaction
      @transaction.save!
      flash.alert = 'A new transaction has been created.'
      redirect_to admin_analyzable_transaction_path(@transaction.id)
    end
  end
end