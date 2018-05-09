class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.integer :order
      t.string :estado
      t.string :string

      t.timestamps
    end
  end
end
