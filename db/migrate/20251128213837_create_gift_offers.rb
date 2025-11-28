class CreateGiftOffers < ActiveRecord::Migration[8.1]
  def change
    create_table :gift_offers do |t|
      t.string :store_name, null: false
      t.decimal :price,      precision: 10, scale: 2, null: false
      t.string  :currency,   null: false, default: "USD"
      t.string :url
      t.decimal :rating,     precision: 3, scale: 2
      t.references :gift, null: false, foreign_key: true

      t.timestamps
    end

    add_index :gift_offers, [:gift_id, :store_name]
  end
end
