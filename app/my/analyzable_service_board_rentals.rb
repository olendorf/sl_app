# frozen_string_literal: true

ActiveAdmin.register_page 'Service Board Rentals', namespace: :my do
  # include ShopData
  menu parent: 'Data', label: 'Service Board Rentals',
       priority: 4,
       if: proc { current_user.service_board_payments.size.positive? }

  content do
    panel 'Recent Service Board Payments' do
      rent_payments = current_user.service_board_payments
                                  .includes(:transactable).order('created_at DESC')
      paginated_collection(
        rent_payments.page(params[:board_payment_page]).per(20),
        param_name: 'board_payment_page',
        entry_name: 'Service Board Payment',
        download_links: false
      ) do
        table_for collection do
          column 'Date/Time', &:created_at
          column 'Renter', &:target_name
          column 'Board' do |board_payment|
            link_to board_payment.transactable.object_name,
                    my_service_board_path(board_payment.transactable)
          end
          column :amount
          column 'Location' do |board_payment|
            board_payment.transactable.decorate.slurl
          end
        end
      end
    end

    panel 'Current Service Board Renters' do
      data = Kaminari.paginate_array(
        ServiceBoardData.service_board_renters(current_user)
      )
                     .page(params[:renter_page]).per(10)
      paginated_collection(data, param_name: 'renter_page',
                                 entry_name: 'Renter',
                                 download_links: false) do
        table_for data do
          column 'Renter' do |renter|
            renter[:renter_name]
          end
          column 'Shops Rented' do |renter|
            renter[:shops]
          end
          column 'Weekly Rent' do |renter|
            renter[:weekly_rent]
          end
        end
      end
    end

    panel '' do
      div class: 'column lg' do
        render partial: 'service_board_rental_status'
      end
    end

    panel '' do
      div class: 'column lg' do
        render partial: 'service_board_status_timeline'
      end
    end

    panel '' do
      div class: 'column lg' do
        render partial: 'service_board_status_ratio_timeline'
      end
    end

    panel '' do
      div class: 'column lg' do
        render partial: 'region_revenue_bar_chart'
      end
    end

    panel '' do
      div class: 'column lg' do
        render partial: 'rental_income_timeline'
      end
    end
  end
end
