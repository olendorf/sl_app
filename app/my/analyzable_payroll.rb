# frozen_string_literal: true

ActiveAdmin.register_page 'Payroll', namespace: :my do
  menu label: 'Payroll',
       priority: 12,
       if: proc { current_user.work_sessions.size.positive? }
         
    content do 
      panel '' do 
        div(class: 'column sm') do 
          h2('Recent Work Sessions', class: 'table-name')
          work_sessions = current_user.work_sessions.includes(:employee)
                              .order('created_at DESC')
          paginated_collection(work_sessions.page(params[:work_session_page]).per(10),
                                    param_name: 'work_session_page',
                                    entry_name: 'Work Sessions',
                                    download_links: false) do 
            table_for collection do 
              column 'Clocked In', &:created_at
              column 'Clocked Out', &:stopped_at
              column 'Employee' do |work_session|
                link_to work_session.employee.avatar_name, 
                          my_employee_path(work_session.employee)
              end
              column 'Duration (hours)' do |work_session|
                work_session.duration.nil? ? nil : work_session.duration.round(2)
              end
              column 'Pay' do |work_session|
                work_session.pay.nil? ? nil : "L$ #{work_session.pay}"
              end
            end
          end
        end
        
        div(class: 'column sm') do 
          h2('Employees', class: 'table-name')
          employees = current_user.employees.order('pay_owed DESC')
          paginated_collection(employees.page(params[:employee_page]).per(10),
                                  param_name: 'employee_page',
                                  entry_name: 'Employees',
                                  download_links: false) do
            table_for collection do 
              column 'Employee' do |employee|
                link_to employee.avatar_name, my_employee_path(employee)
              end
              column :hourly_pay
              column :max_hours
              column 'Recent hours worked'do |employee|
                employee.hours_worked.round(2)
              end
              column :pay_owed
              column 'Date hired', &:created_at
            end
          end
        end
      end
      
      panel 'Payroll Timeline ' do 
        div class: 'column lg' do 
          render partial: 'payroll_timeline'
        end
      end
      
      panel '' do 
        div(class: 'column sm') do 
          h2('Work Hours Heat Map')
          render partial: 'hours_heatmap'
        end
        
        
        div(class: 'column sm') do 
          h2('Payment Heat Map')
          render partial: 'payment_heatmap'
        end
        
      end
      

    end




  controller do
    # def scoped_collection
    #   super.includes(%i[session transactable])
    # end
  end
end
