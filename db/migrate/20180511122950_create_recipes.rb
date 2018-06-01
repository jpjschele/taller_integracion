class CreateRecipes < ActiveRecord::Migration[5.1]
  def change
    create_table :recipes do |t|
      t.string :sku
      t.string :name
      t.integer :batch
      t.integer :ingredients
      t.integer :apple
      t.integer :orange
      t.integer :strawberry
      t.integer :raspberry
      t.integer :peach
      t.integer :blueberry

      t.timestamps
    end
  end
end
