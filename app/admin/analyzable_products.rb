ActiveAdmin.register Analyzable::Product, as: 'Product' do
  
  menu label: 'Product'
  
  
  index titles: 'Products' do
    selectable_column
    column 'Product Name' do |product|
      link_to product.product_name, admin_product_path(product)
    end
    
    column 'Owner' do |product|
      link_to product.user.avatar_name, admin_user_path(product.user)
    end
    column 'Product Links' do |product|
      product.product_links.size
    end
    column 'Revenue' do |product|
      product.revenue
    end
    column 'Units Sold' do |product|
      product.transactions_count
    end
    column :created_at
    column :updated_at
    actions
    
  end


  filter :product_name
  filter :user_avatar_name, as: :string, label: 'Owner'
  filter :revenue
  filter :transactions_count
  filter :created_at
  
  show title: :product_name do 
    attributes_table do 
      row 'Image' do |product|
        if product.image_key
          image_tag "http://secondlife.com/app/image/#{product.image_key}/1"
        else
          image_tag 'no_image_available'
        end
      end
      row :product_name
      row 'Aliases' do |vendor|
        vendor.product_links.collect { |link| link.link_name}.join('; ')
      end
      row 'Owner', sortable: 'users.avatar_name' do |vendor|
        if vendor.user
          link_to vendor.user.avatar_name, admin_user_path(vendor.user)
        else
          'Orphan'
        end
      end
      row 'Sales' do |vendor|
        "#{vendor.revenue} $L (#{vendor.transactions_count}})"
      end
      row :created_at
      row :updated_at
    end
    
    panel 'Sales' do 
      paginated_collection(
        resource.sales.page(
          params[:sales_page]
        ).per(10), param_name: 'sales_page'
      ) do 
        table_for collection.order(created_at: :desc), download_links: false do 
          column 'Date/Time' do |sale|
            link_to sale.created_at.to_s(:long), admin_transaction_path(sale)
          end
          column 'Customer', &:target_name
          column 'amount'
        end
      end
    end
  end
  
  permit_params :product_name, :image_key, product_links_attributes: [:id, :link_name, :_destroy]
  
  form do |f|
    f.inputs do 
      f.input :product_name
      f.input :image_key
      f.has_many :product_links,
        label: 'Aliases',
        new_record: true,
        allow_destroy: true do |pl|
          pl.input :link_name
      end
    end
    f.actions
  end
  
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :user_id, :image_key, :product_name
  #
  # or
  #
  # permit_params do
  #   permitted = [:user_id, :image_key, :product_name]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  controller do 
    # def scoped_collection
      # super.includes(:user)
    # end
  end
end
