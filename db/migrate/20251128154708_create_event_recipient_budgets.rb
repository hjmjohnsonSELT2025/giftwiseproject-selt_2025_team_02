class CreateEventRecipientBudgets < ActiveRecord::Migration[8.1]
  def change
    create_table :event_recipient_budgets do |t|
      t.references :event_recipient, null: false, foreign_key: true
      t.decimal :budget, precision: 10, scale: 2, null: false, default: 0
      t.decimal :spent, precision: 10, scale: 2, null: false, default: 0

      t.timestamps
    end
  end
end
