# frozen_string_literal: true

ActiveAdmin.register_page 'Tips', namespace: :my do
  menu parent: 'Data', label: 'Tips',
       priority: 2,
       if: proc { current_user.tips.size.positive? }
         
         
  content title: proc { I18n.t('active_admin.tips') } do 
    panel '' do 
      div class: 'column md' do 
        tips = current_user.tips.includes(:session, :transactable).order('created_at DESC')
        h2 'Tips', class: 'table-name'
        paginated_collection(tips.page(params[:tip_page]).per(10),
                                       param_name: 'tip_page',
                                       entry_name: 'Tips',
                                       download_links: false) do 
          table_for collection do 
            column 'Date/Time', &:created_at
            column 'Tipper', &:target_name
            column 'Employee' do |tip|
              if tip.session
                tip.session.avatar_name
              else
                'Anonymous'
              end
            end
            column 'Amount', &:amount
            column 'Location' do |tip|
              tip.transactable.decorate.slurl
            end
          end
        end
      end 
      
      div class: 'column md' do 
        h2 'Employees', class: 'table-name'
      end
    end
  end
  
  controller do
    def scoped_collection
      super.includes(%i[session transactable])
    end
  end
end
