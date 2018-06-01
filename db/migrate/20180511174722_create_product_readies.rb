class CreateProductReadies < ActiveRecord::Migration[5.1]
  def change
    create_table :product_readies do |t|
      t.string :productoId
      t.belongs_to :order, foreign_key: true

      t.timestamps
    end
  end
end
