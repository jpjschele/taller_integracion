class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.string :name
      t.string :state
      t.string :sku
      t.integer :quantity

      t.timestamps
    end
  end
end
