# frozen_string_literal: true

ActiveAdmin.register_page 'Donations', namespace: :my do
  menu parent: 'Data', label: 'Donations',
       priority: 1,
       if: proc { current_user.donations.size.positive? }
         

  content title: proc { I18n.t('active_admin.donations') } do
    panel '' do
      donations = current_user.donations.order('created_at DESC')

      div class: 'column md' do
        h2 'Donations', class: 'table-name'
        paginated_collection(donations.page(params[:donation_page]).per(10),
                             param_name: 'donation_page',
                             entry_name: 'Donations',
                             download_links: false) do
          table_for collection do
            column 'Date/Time', &:created_at
            column 'Name', &:target_name
            column :amount
          end
        end
      end
      div class: 'column md' do
        h2 'Donors', class: 'table-name'
        amounts = current_user.donations.group(:target_name).sum(:amount).sort_by do |_key, value|
          -value
        end.to_h
        counts = current_user.donations.group(:target_name).count
        data = Kaminari.paginate_array(
          amounts.collect { |k, v| { avatar: k, amount: v, count: counts[k] } }
        ).page(params[:donor_page]).per(10)
        paginated_collection(data, param_name: 'donor_page',
                                   entry_name: 'Donors',
                                   download_links: false) do
          table_for data do
            column 'Donor' do |item|
              item[:avatar]
            end
            column 'Donations' do |item|
              item[:count]
            end
            column 'Total $L' do |item|
              item[:amount]
            end
          end
        end
        # div id: 'donor_footer' do
        #   paginate data, param_name: 'donor_page'
        # end
      end
    end
    panel '' do
      div class: 'column md' do
        render partial: 'donations_histogram'
      end
      div class: 'column md' do
        render partial: 'donors_histogram'
      end
    end
    panel '' do
      div class: 'column lg' do
        render partial: 'donor_scatter_plot'
      end
    end

    # div class: 'blank_slate_container', id: 'dashboard_default_message' do
    #   span class: 'blank_slate' do
    #     span I18n.t('active_admin.dashboard_welcome.welcome')
    #     small I18n.t('active_admin.dashboard_welcome.call_to_action')
    #   end
    # ed
  end
end
