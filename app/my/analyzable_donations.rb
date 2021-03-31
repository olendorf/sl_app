# frozen_string_literal: true

ActiveAdmin.register Analyzable::Transaction, as: 'Donation', namespace: :my do
  menu parent: 'Data', label: 'Donations', priority: 1, if: proc{ current_user.transactions.size > 0 }

  actions :all, except: %i[destroy show edit update]

  config.sort_order = 'created_at_desc'

  scope_to :current_user, association_method: :donations

  index title: 'Donations' do
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
    column 'Donor', sortable: :target_name do |donation|
      donation.target_name
    end
    column 'Donation Box', sortable: 'abstract_web_objects.object_name' do |donation|
      donation_box = AbstractWebObject.find(donation.web_object_id).actable
      link_to donation_box.object_name, my_donation_box_path(donation_box)
    end
    actions defaults: false do |donation|
      link_to('View', my_transaction_path(donation))+
      link_to('Edit', edit_my_transaction_path(donation))
    end
  end
  
  index

  filter :target_name, label: 'Donor'
  filter :amount
  filter :created_at
  filter :web_object_id, as: :select, collection: proc{ current_user.donation_boxes.collect { |box| [box.object_name, box.abstract_web_object.id]} }
  
  controller do
    def scoped_collection
      super.includes :web_object # prevents N+1 queries to your database
    end
  end

 
end
