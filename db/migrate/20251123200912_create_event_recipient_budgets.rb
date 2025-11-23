class CreateEventRecipientBudgets < ActiveRecord::Migration[8.1]
  def change
    create_table :event_recipient_budgets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.references :recipient, null: false, foreign_key: true
      t.integer :total_budget, null: false, default: 0
      t.integer :spent_budget, null: false, default: 0

      t.timestamps
    end
  end
end
