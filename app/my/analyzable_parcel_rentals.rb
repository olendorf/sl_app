# frozen_string_literal: true

ActiveAdmin.register_page 'Parcel Rentals', namespace: :my do
  menu parent: 'Data', label: 'Parcel Rentals',
       priority: 3,
       if: proc { current_user.parcel_payments.size.positive? }

  content do
    panel 'Recent Tier Payments' do
      tier_payments = current_user.parcel_payments.includes(:transactable).order('created_at DESC')
      paginated_collection(
        tier_payments.page(params[:parcel_payment_page]).per(20),
        param_name: 'parcel_payment_page',
        entry_name: 'Tier Payment',
        download_links: false
      ) do
        table_for collection do
          column 'Date/Time', &:created_at
          column 'Renter', &:target_name
          column 'Parcel' do |parcel_payment|
            parcel_payment.transactable.parcel_name
          end
          column :amount
          column 'Location' do |parcel_payment|
            parcel_payment.transactable.decorate.slurl
          end
        end
      end
    end

    panel '' do
      div class: 'column lg' do
        render partial: 'parcel_status_treemap'
      end
    end

    panel '' do
      div class: 'column lg' do
        render partial: 'parcel_status_timeline'
      end
    end
    
    panel '' do
      div class: 'column lg' do
        render partial: 'parcel_status_ratio_timeline'
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
