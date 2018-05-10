# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'roo'
  xlsx = Roo::Spreadsheet.open('./public/Grupos-1.xlsx')
  xlsx.default_sheet = 'Formulas'
  (2..70).each do |m|
    ProductInfo.create(
    sku: xlsx.cell(m,1),
    product: xlsx.cell(m,2),
    lote: xlsx.cell(m,3),
    nro: xlsx.cell(m,4),
    man: xlsx.cell(m,5),
    nar: xlsx.cell(m,6),
    fru: xlsx.cell(m,7),
    fra: xlsx.cell(m,8),
    dur: xlsx.cell(m,9),
    ara: xlsx.cell(m,10))
  end
