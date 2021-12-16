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
        render partial: 'region_revenue_bar_chart'
      end
    end

    panel '' do
      div class: 'column lg' do
        render partial: 'parcel_status_timeline'
      end
    end

    panel '' do
      div class: 'column lg' do
        render partial: 'rental_income_timeline'
      end
    end
  end

  # content title: proc { I18n.t } do
  #   panel 'Recent Sales' do
  #     sales = current_user.sales.includes(:transactable, :inventory,
  #                                         :product).order('created_at DESC')
  #     paginated_collection(sales.page(params[:sales_page]).per(10),
  #                         param_name: 'sales_page',
  #                         entry_name: 'Sales',
  #                         download_links: false) do
  #       table_for collection do
  #         column 'Date/Time', &:created_at
  #         column 'Customer', &:target_name
  #         column 'Amount', &:amount
  #         column 'Vendor' do |sale|
  #           if sale.transactable
  #             link_to sale.transactable.object_name, my_vendor_path(sale.transactable)
  #           else
  #             'Market Place'
  #           end
  #         end
  #         column 'Inventory' do |sale|
  #           if sale.inventory
  #             link_to sale.inventory.inventory_name, my_inventory_path(sale.inventory)
  #           end
  #         end
  #         column 'Product' do |sale|
  #           link_to sale.product.product_name, my_product_path(sale.product) if sale.product
  #         end
  #       end
  #     end
  #   end

  #   panel 'Data from the last month' do
  #     div class: 'column sm' do
  #       h2('Sales by Customer', class: 'table-name')
  #       target_amounts = current_user.sales.group(:target_name).sum(:amount)
  #       data = current_user.sales.where('created_at >= ?',
  #                                       1.month.ago).group(:target_name).count.collect do |k, v|
  #         { customer: k, items_sold: v, total_paid: target_amounts[k] }
  #       end
  #       data = data.sort_by { |d| d[:total_paid] }.reverse

  #       data = Kaminari.paginate_array(
  #         data
  #       ).page(params[:customer_page]).per(10)

  #       paginated_collection(data, param_name: 'customer_page',
  #                                 entry_name: 'Customers',
  #                                 download_links: false) do
  #         table_for collection do
  #           column :customer
  #           column :items_sold
  #           column :total_paid
  #         end
  #       end
  #     end

  #     div class: 'column sm' do
  #       h2('Sales by Inventory', class: 'table-name')
  #       sales_data = current_user.sales.where('analyzable_transactions.created_at >= ?',
  #                                             1.month.ago).joins(:inventory)
  #       sales_amounts = sales_data.group(:inventory_name).sum(:amount)
  #       data = sales_data.joins(:inventory).group(:inventory_name).count.collect do |k, v|
  #         { inventory: k, items_sold: v, total_paid: sales_amounts[k] }
  #       end
  #       data = data.sort_by { |d| d[:total_paid] }.reverse

  #       data = Kaminari.paginate_array(
  #         data
  #       ).page(params[:inventory_page]).per(10)

  #       paginated_collection(data, param_name: 'inventory_page',
  #                                 entry_name: 'Inventory',
  #                                 download_links: false) do
  #         table_for collection do
  #           column 'Inventory' do |i|
  #             link_to i[:inventory],
  #                     my_inventory_path(
  #                       current_user.inventories.find_by_inventory_name(i[:inventory])
  #                     )
  #           end
  #           column :items_sold
  #           column :total_paid
  #         end
  #       end
  #     end

  #     div class: 'column sm' do
  #       h2('Sales by Product', class: 'table-name')
  #       sales_data = current_user.sales.where('analyzable_transactions.created_at >= ?',
  #                                             1.month.ago).joins(:product)
  #       sales_amounts = sales_data.group(:product_name).sum(:amount)
  #       data = sales_data.joins(:inventory).group(:product_name).count.collect do |k, v|
  #         { product: k, items_sold: v, total_paid: sales_amounts[k] }
  #       end
  #       data = data.sort_by { |d| d[:total_paid] }.reverse

  #       data = Kaminari.paginate_array(
  #         data
  #       ).page(params[:product_page]).per(10)

  #       paginated_collection(data, param_name: 'product_page',
  #                                 entry_name: 'Product',
  #                                 download_links: false) do
  #         table_for collection do
  #           column 'Product' do |i|
  #             link_to i[:product],
  #                     my_product_path(current_user.products.find_by_product_name(i[:product]))
  #           end
  #           column :items_sold
  #           column :total_paid
  #         end
  #       end
  #     end
  #   end

  #   panel '' do
  #     div class: 'column lg' do
  #       render partial: 'product_revenue_timeline'
  #     end

  #     div class: 'column lg' do
  #       render partial: 'product_sales_timeline'
  #     end

  #     div class: 'column lg' do
  #       render partial: 'inventory_revenue_timeline'
  #     end

  #     div class: 'column lg' do
  #       render partial: 'inventory_sales_timeline'
  #     end
  #   end
  # end

  # # content title: proc { I18n.t('active_admin.sales') } do
  # #   panel '' do
  # #     div class: 'column md' do
  # #       tips = current_user.tips.includes(:session, :transactable).order('created_at DESC')
  # #       h2 'Tips', class: 'table-name'
  # #       paginated_collection(tips.page(params[:tip_page]).per(10),
  # #                           param_name: 'tip_page',
  # #                           entry_name: 'Tips',
  # #                           download_links: false) do
  # #         table_for collection do
  # #           column 'Date/Time', &:created_at
  # #           column 'Tipper', &:target_name
  # #           column 'Employee' do |tip|
  # #             if tip.session
  # #               tip.session.avatar_name
  # #             else
  # #               'Anonymous'
  # #             end
  # #           end
  # #           column 'Amount', &:amount
  # #           column 'Location' do |tip|
  # #             tip.transactable.decorate.slurl
  # #           end
  # #         end
  # #       end
  # #     end

  # #     div class: 'column md' do
  # #       counts = current_user.sessions.group(:avatar_name).count
  # #       data = current_user.sessions.group(:avatar_name).sum(:duration).collect do |k, v|
  # #         { avatar_name: k, time_spent: v, sessions: counts[k], tip_count: 0, total_tips: 0 }
  # #       end
  # #       current_user.tips.includes(:session).each do |t|
  # #         item = data.find { |d| d[:avatar_name] == t.session.avatar_name }
  # #         item[:total_tips] += t.amount
  # #         item[:tip_count] += 1
  # #       end
  # #       data = data.sort_by { |d| d[:total_tips] }.reverse
  # #       h2 'Employees', class: 'table-name'
  # #       data = Kaminari.paginate_array(
  # #         data
  # #       ).page(params[:donor_page]).per(10)

  # #       paginated_collection(data, param_name: 'donor_page',
  # #                                 entry_name: 'Employees',
  # #                                 download_links: false) do
  # #         table_for data do
  # #           column 'Employee' do |item|
  # #             item[:avatar_name]
  # #           end
  # #           column 'Time Spent (mins)' do |item|
  # #             item[:time_spent]
  # #           end
  # #           column 'Sessions' do |item|
  # #             item[:sessions]
  # #           end

  # #           column 'Tip Count' do |item|
  # #             item[:tip_count]
  # #           end

  # #           column 'Total Tips' do |item|
  # #             item[:total_tips]
  # #           end
  # #         end
  # #       end
  # #     end
  # #   end

  # #   panel '' do
  # #     div class: 'column md' do
  # #       counts = current_user.tips.group(:target_name).count
  # #       data = current_user.tips.group(:target_name).sum(:amount).collect do |k, v|
  # #         { avatar_name: k, tip_count: counts[k], total_tips: v }
  # #       end
  # #       data = data.sort_by { |d| d[:total_tips] }.reverse
  # #       data = Kaminari.paginate_array(data).page(params[:tipper_page]).per(10)

  # #       h2 'Tippers', class: 'table-name'

  # #       paginated_collection(data, param_name: 'tipper_page',
  # #                                 entry_name: 'Tipper',
  # #                                 download_links: false) do
  # #         table_for data do
  # #           column 'Tipper' do |item|
  # #             item[:avatar_name]
  # #           end
  # #           column 'Tips' do |item|
  # #             item[:tip_count]
  # #           end
  # #           column 'Total Tipped' do |item|
  # #             item[:total_tips]
  # #           end
  # #         end
  # #       end
  # #     end
  # #   end

  # #   panel '' do
  # #     div class: 'column md' do
  # #       render partial: 'tips_histogram'
  # #     end

  # #     div class: 'column md' do
  # #       render partial: 'tippers_histogram'
  # #     end
  # #   end
  # #   panel '' do
  # #     div class: 'column md' do
  # #       render partial: 'sessions_histogram'
  # #     end

  # #     div class: 'column md' do
  # #       render partial: 'employee_time_histogram'
  # #     end
  # #   end

  # #   panel '' do
  # #     div class: 'column md' do
  # #       render partial: 'employee_tip_totals_histogram'
  # #     end

  # #     div class: 'column md' do
  # #       render partial: 'employee_tip_counts_histogram'
  # #     end
  # #   end

  # #   panel '' do
  # #     div class: 'column lg' do
  # #       render partial: 'tips_timeline'
  # #     end
  # #   end
  # # end

  # controller do
  #   def scoped_collection
  #     super.includes(%i[session transactable])
  #   end
  # end
end
