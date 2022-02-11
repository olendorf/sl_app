# frozen_string_literal: true

ActiveAdmin.register_page 'Shop Rentals', namespace: :my do
  # include ShopData
  menu parent: 'Data', label: 'Shop Rentals',
       priority: 3,
       if: proc { current_user.shop_payments.size.positive? }

  content do
    panel 'Recent Shop Rental Payments' do
      tier_payments = current_user.shop_payments.includes(:transactable).order('created_at DESC')
      paginated_collection(
        tier_payments.page(params[:shop_payment_page]).per(20),
        param_name: 'shop_payment_page',
        entry_name: 'Shop Payment',
        download_links: false
      ) do
        table_for collection do
          column 'Date/Time', &:created_at
          column 'Renter', &:target_name
          column 'Shop' do |shop_payment|
            link_to shop_payment.transactable.object_name,
                    my_shop_rental_box_path(shop_payment.transactable)
          end
          column :amount
          column 'Location' do |shop_payment|
            shop_payment.transactable.decorate.slurl
          end
        end
      end
    end

    panel 'Current Shop Renters' do
      data = Kaminari.paginate_array(ShopData.shop_renters(current_user))
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
        render partial: 'shop_rental_status'
      end
    end

    panel '' do
      div class: 'column lg' do
        render partial: 'shop_status_timeline'
      end
    end

    panel '' do
      div class: 'column lg' do
        render partial: 'shop_status_ratio_timeline'
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
