class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :name, null: false # name required
      t.date :event_date, null: false # date required
      t.time :event_time
      t.string :location
      t.decimal :budget, precision: 10, scale: 2
      t.references :user, null: false, foreign_key: true# every event belongs to a user

      t.timestamps
    end
    add_index :events, [:user_id, :event_date]
  end
end
