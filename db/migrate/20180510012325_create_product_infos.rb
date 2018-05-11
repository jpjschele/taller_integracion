class CreateProductInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :product_infos do |t|
      t.integer :sku
      t.string :product
      t.integer :lote
      t.integer :nro
      t.integer :man
      t.integer :nar
      t.integer :fru
      t.integer :fra
      t.integer :dur
      t.integer :ara

      t.timestamps
    end
  end
end
