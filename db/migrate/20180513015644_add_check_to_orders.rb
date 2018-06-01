class AddCheckToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :check, :boolean
  end
end
