class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.date :date
      t.references :user, null: false, foreign_key: true
      t.integer :total_budget, null: false, default: 0
      t.integer :spent_budget, null: false, default: 0
      
      t.timestamps
    end
  end
end
