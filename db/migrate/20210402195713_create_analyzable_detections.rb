class CreateAnalyzableDetections < ActiveRecord::Migration[6.0]
  def change
    create_table :analyzable_detections do |t|
      t.integer :visit_id
      t.string :position

      t.timestamps
    end
  end
end
