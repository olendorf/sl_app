# frozen_string_literal: true

ActiveAdmin.register Analyzable::Employee, as: 'Employee', namespace: :my do
  index title: 'Employees' do
    selectable_column

    scope_to :current_user, association_method: :servers

    column 'Employee' do |employee|
      link_to employee.avatar_name, my_employee_path(employee)
    end
    column :hourly_pay
    column :max_hours
    column raw('Hours worked <br> This pay period') do |employee|
      employee.hours_worked.round(2)
    end
    column raw('Pay Owed <br> This pay period'), :pay_owed
    column 'Date Hired', :created_at
    actions
  end

  filter :avatar_name, as: :string, label: 'Employee'
  filter :hourly_pay
  filter :max_hours
  filter :hours_worked, label: 'Hours worked this pay perid'
  filter :pay_owed
  filter :created_at, label: 'Date hired'

  show title: :avatar_name do
    attributes_table do
      row :avatar_key
      row :hourly_pay
      row :max_hours
      row 'Hours worked this pay period' do |employee|
        employee.hours_worked.round(2)
      end
      row :pay_owed
      row 'Date hired', &:created_at
      row :updated_at
    end

    panel 'Work Activity' do
      paginated_collection(
        resource.work_sessions.order(created_at: :desc).page(
          params[:work_session_page]
        ).per(10), param_name: 'work_session_page', download_links: false
      ) do
        table_for collection do
          column 'Clocked in', &:created_at
          column 'Clocked out', &:stopped_at
          column 'Duration' do |employee|
            employee.duration.nil? ? nil : employee.duration.round(2)
          end
          column :pay
        end
      end
    end
  end

  permit_params do
    permitted = %i[hourly_pay max_hours]
    permitted << %i[avatar_key avatar_name user_id] if action_name == 'create'
    permitted
  end

  form title: proc { "Edit #{resource.avatar_name}" } do |f|
    f.inputs do
      if f.object.new_record?
        f.input :avatar_name
        f.input :avatar_key
      end
      f.input :hourly_pay
      f.input :max_hours
      f.input :user_id, input_html: { value: current_user.id }, as: :hidden
    end
    f.actions
  end

  controller do
    def scoped_collection
      super.includes(%i[user])
    end
  end
end
