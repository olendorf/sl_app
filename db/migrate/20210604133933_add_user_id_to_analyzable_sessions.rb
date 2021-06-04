class AddUserIdToAnalyzableSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :analyzable_sessions, :user_id, :integer
  end
end
