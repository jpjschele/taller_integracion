# require 'csv'
#
# Spree::Core::Engine.load_seed if defined?(Spree::Core)
# Spree::Auth::Engine.load_seed if defined?(Spree::Auth)
# Spree::Sample.load_sample("shipping_categories")
#
# csv_text = File.read(Rails.root.join('lib', 'seeds', 'real_estate_transactions.csv'))
# csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')
# default_shipping_category = Spree::ShippingCategory.find_by!(name: "Default")
#
# csv.each do |row|
#   p = Spree::Product.new
#   p.name = row['name']
#   p.price = row['price']
#   p.currency = 'CLP'
#   p.description = FFaker::Lorem.paragraph
#   p.shipping_category = default_shipping_category
#   variant_attrs = {sku: row['sku'], cost_price: 100}
#   p.master.update_attributes!(variant_attrs)
#   p.save
# end

#Spree::StockLocation.create(name:"TiendaJugos")

Spree::Core::Engine.load_seed if defined?(Spree::Core)
Spree::Auth::Engine.load_seed if defined?(Spree::Auth)
Spree::Sample.load_sample("shipping_categories")
#Spree::Sample.load_sample("products")

products = [
   {
    name: "Manzana",
    price: 15.99
  },
  {
    name: "Naranja",
    price: 15.99
  },
  {
    name: "Frutilla",
    price: 15.99
  },
  {
    name: "Frambuesa",
    price: 15.99
  },
  {
    name: "Durazno",
    price: 15.99
  },
  {
    name: "Arándano",
    price: 15.99
  },
  {
    name: "Jugo Manzana",
    price: 15.99
  },
  {
    name: "Jugo Manzana-Naranja",
    price: 15.99
  },
  {
    name: "Jugo Manzana-Naranja-Frutilla",
    price: 15.99
  },
  {
    name: "Jugo Manzana-Naranja-Frutilla-Frambuesa",
    price: 15.99
  },
  {
    name: "Jugo Manzana-Naranja-Frutilla-Frambuesa-Durazno",
    price: 15.99
  },
  {
    name: "Jugo Fruit Super Punch",
    price: 15.99
  },
  {
    name: "Jugo Manzana-Naranja-Frutilla-Frambuesa-Arándano",
    price: 15.99
  },
  {
    name: "Jugo Manzana-Naranja-Frutilla-Durazno",
    price: 15.99
  },
  {
    name: "Jugo Manzana-Naranja-Frutilla-Durazno-Arándano",
    price: 15.99
  },
  {
    name: "Jugo Manzana-Naranja-Frutilla-Arándano",
    price: 15.99
  },
  {
    name: "Jugo Manzana-Naranja-Frambuesa",
    price: 15.99
  },
  {
    name: "Jugo Manzana-Naranja-Frambuesa-Durazno",
    price: 15.99
  },
  {
    name: "Jugo Manzana-Naranja-Frambuesa-Durazno-Arándano",
    price: 15.99
  },
  {
    name: "Jugo Manzana-Naranja-Frambuesa-Arándano",
    price: 15.99
  }
]

#Spree::ShippingCategory.find_or_create_by!(name: 'Default')
default_shipping_category = Spree::ShippingCategory.find_by!(name: "Default")


products.each do |product_attrs|
  Spree::Config[:currency] = "USD"
  new_product = Spree::Product.where(name: product_attrs[:name],
                                     tax_category: product_attrs[:tax_category]).first_or_create! do |product|
    product.price = product_attrs[:price]
    product.description = FFaker::Lorem.paragraph
    product.available_on = Time.zone.now
    product.shipping_category = default_shipping_category
  end

  if new_product
    new_product.save
  end
end


Manzana = Spree::Product.find_by!(name: "Manzana")
Naranja = Spree::Product.find_by!(name: "Naranja")
Frutilla = Spree::Product.find_by!(name: "Frutilla")
Frambuesa = Spree::Product.find_by!(name: "Frambuesa")
Durazno = Spree::Product.find_by!(name: "Durazno")
Arándano = Spree::Product.find_by!(name: "Arándano")
Jugo_Manzana = Spree::Product.find_by!(name: "Jugo Manzana")
Jugo_Manzana_Naranja = Spree::Product.find_by!(name: "Jugo Manzana-Naranja")
Jugo_Manzana_Naranja_Frutilla = Spree::Product.find_by!(name: "Jugo Manzana-Naranja-Frutilla")
Jugo_Manzana_Naranja_Frutilla_Frambuesa = Spree::Product.find_by!(name: "Jugo Manzana-Naranja-Frutilla-Frambuesa")
Jugo_Manzana_Naranja_Frutilla_Frambuesa_Durazno = Spree::Product.find_by!(name: "Jugo Manzana-Naranja-Frutilla-Frambuesa-Durazno")
Jugo_Fruit_Super_Punch = Spree::Product.find_by!(name: "Jugo Fruit Super Punch")
Jugo_Manzana_Naranja_Frutilla_Frambuesa_Arándano = Spree::Product.find_by!(name: "Jugo Manzana-Naranja-Frutilla-Frambuesa-Arándano")
Jugo_Manzana_Naranja_Frutilla_Durazno = Spree::Product.find_by!(name: "Jugo Manzana-Naranja-Frutilla-Durazno")
Jugo_Manzana_Naranja_Frutilla_Durazno_Arándano = Spree::Product.find_by!(name: "Jugo Manzana-Naranja-Frutilla-Durazno-Arándano")
Jugo_Manzana_Naranja_Frutilla_Arándano = Spree::Product.find_by!(name: "Jugo Manzana-Naranja-Frutilla-Arándano")
Jugo_Manzana_Naranja_Frambuesa = Spree::Product.find_by!(name: "Jugo Manzana-Naranja-Frambuesa")
Jugo_Manzana_Naranja_Frambuesa_Durazno = Spree::Product.find_by!(name: "Jugo Manzana-Naranja-Frambuesa-Durazno")
Jugo_Manzana_Naranja_Frambuesa_Durazno_Arándano = Spree::Product.find_by!(name: "Jugo Manzana-Naranja-Frambuesa-Durazno-Arándano")
Jugo_Manzana_Naranja_Frambuesa_Arándano = Spree::Product.find_by!(name: "Jugo Manzana-Naranja-Frambuesa-Arándano")


masters = {
  Manzana => {
    sku: "20",
    cost_price: 17,
  },
  Naranja => {
    sku: "30",
    cost_price: 17
  },
  Frutilla => {
    sku: "40",
    cost_price: 21
  },
  Frambuesa => {
    sku: "50",
    cost_price: 17
  },
  Durazno => {
    sku: "60",
    cost_price: 11
  },
  Arándano => {
    sku: "70",
    cost_price: 17
  },
  Jugo_Manzana => {
    sku: "200000000",
    cost_price: 15
  },
  Jugo_Manzana_Naranja => {
    sku: "230000000",
    cost_price: 17
  },
  Jugo_Manzana_Naranja_Frutilla => {
    sku: "234000000",
    cost_price: 17
  },
  Jugo_Manzana_Naranja_Frutilla_Frambuesa => {
    sku: "234500000",
    cost_price: 17
  },
  Jugo_Manzana_Naranja_Frutilla_Frambuesa_Durazno => {
    sku: "234560000",
    cost_price: 17
  },
  Jugo_Fruit_Super_Punch => {
    sku: "234567000",
    cost_price: 17
  },
  Jugo_Manzana_Naranja_Frutilla_Frambuesa_Arándano => {
    sku: "234570000",
    cost_price: 17
  },
  Jugo_Manzana_Naranja_Frutilla_Durazno => {
    sku: "234600000",
    cost_price: 17
  },
  Jugo_Manzana_Naranja_Frutilla_Durazno_Arándano => {
    sku: "234670000",
    cost_price: 17
  },
  Jugo_Manzana_Naranja_Frutilla_Arándano => {
    sku: "234700000",
    cost_price: 17
  },
  Jugo_Manzana_Naranja_Frambuesa => {
    sku: "235000000",
    cost_price: 17
  },
  Jugo_Manzana_Naranja_Frambuesa_Durazno => {
    sku: "235600000",
    cost_price: 17
  },
  Jugo_Manzana_Naranja_Frambuesa_Durazno_Arándano => {
    sku: "235670000",
    cost_price: 17
  },
  Jugo_Manzana_Naranja_Frambuesa_Arándano => {
    sku: "235700000",
    cost_price: 17
  }
}

masters.each do |product, variant_attrs|
  product.master.update_attributes!(variant_attrs)
end

Spree::StockLocation.create(name:"JuiceStoreStock")


# ----- API 
require 'roo'
  xlsx = Roo::Spreadsheet.open('./public/Grupos-1.xlsx')
  xlsx.default_sheet = 'Formulas'
  (2..70).each do |m|
    Recipe.create(
    sku: xlsx.cell(m,1),
    name: xlsx.cell(m,2),
    batch: xlsx.cell(m,3),
    ingredients: xlsx.cell(m,4),
    apple: xlsx.cell(m,5),
    orange: xlsx.cell(m,6),
    strawberry: xlsx.cell(m,7),
    raspberry: xlsx.cell(m,8),
    peach: xlsx.cell(m,9),
    blueberry: xlsx.cell(m,10))
  end
