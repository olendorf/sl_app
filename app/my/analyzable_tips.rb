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
        counts = current_user.sessions.group(:avatar_name).count
        data = current_user.sessions.group(:avatar_name).sum(:duration).collect do |k, v|
          { avatar_name: k, time_spent: v, sessions: counts[k], tip_count: 0, total_tips: 0 }
        end
        current_user.tips.includes(:session).each do |t|
          item = data.find { |d| d[:avatar_name] == t.session.avatar_name }
          item[:total_tips] += t.amount
          item[:tip_count] += 1
        end
        data = data.sort_by { |d| d[:total_tips] }.reverse
        h2 'Employees', class: 'table-name'
        data = Kaminari.paginate_array(
          data
        ).page(params[:donor_page]).per(10)

        paginated_collection(data, param_name: 'donor_page',
                                   entry_name: 'Employees',
                                   download_links: false) do
          table_for data do
            column 'Employee' do |item|
              item[:avatar_name]
            end
            column 'Time Spent (mins)' do |item|
              item[:time_spent]
            end
            column 'Sessions' do |item|
              item[:sessions]
            end

            column 'Tip Count' do |item|
              item[:tip_count]
            end

            column 'Total Tips' do |item|
              item[:total_tips]
            end
          end
        end
      end
    end

    panel '' do
      div class: 'column md' do
        counts = current_user.tips.group(:target_name).count
        data = current_user.tips.group(:target_name).sum(:amount).collect do |k, v|
          { avatar_name: k, tip_count: counts[k], total_tips: v }
        end
        data = data.sort_by { |d| d[:total_tips] }.reverse
        data = Kaminari.paginate_array(data).page(params[:tipper_page]).per(10)

        h2 'Tippers', class: 'table-name'

        paginated_collection(data, param_name: 'tipper_page',
                                   entry_name: 'Tipper',
                                   download_links: false) do
          table_for data do
            column 'Tipper' do |item|
              item[:avatar_name]
            end
            column 'Tips' do |item|
              item[:tip_count]
            end
            column 'Total Tipped' do |item|
              item[:total_tips]
            end
          end
        end
      end
    end

    panel '' do
      div class: 'column md' do
        render partial: 'tips_histogram'
      end

      div class: 'column md' do
        render partial: 'tippers_histogram'
      end
    end
    panel '' do
      div class: 'column md' do
        render partial: 'sessions_histogram'
      end

      div class: 'column md' do
        render partial: 'employee_time_histogram'
      end
    end

    panel '' do
      div class: 'column md' do
        render partial: 'employee_tip_totals_histogram'
      end

      div class: 'column md' do
        render partial: 'employee_tip_counts_histogram'
      end
    end

    panel '' do
      div class: 'column lg' do
        render partial: 'tips_timeline'
      end
    end
  end

  controller do
    def scoped_collection
      super.includes(%i[session transactable])
    end
  end
end
