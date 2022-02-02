# frozen_string_literal: true

module Async
  # Handles AJAX requests for data to create charts and tables.
  class SalesController < AsyncController
    def index
      authorize :async, :index?
      render json: send(params['chart'], params['ids']).to_json
    end

    def sales_by_inventory_revenue_timeline(_ids=nil)
      SalesData.sales_by_inventory_revenue_timeline(current_user)
    end

    def sales_by_inventory_items_timeline(_ids = nil)
      SalesData.sales_by_inventory_items_timeline(current_user)
    end


    def sales_by_product_items_timeline(_ids = nil)
      SalesData.sales_by_product_items_timeline(current_user)
    end

    def sales_by_product_revenue_timeline(_ids = nil)
      SalesData.sales_by_product_revenue_timeline(current_user)
    end

    def vendor_sales_timeline(ids)
      SalesData.vendor_sales_timeline(ids)
    end

    def inventory_sales_timeline(ids)
      SalesData.inventory_sales_timeline(ids)
    end

    def product_sales_timeline(ids)
      SalesData.product_sales_timeline(ids)
    end

  end
end
