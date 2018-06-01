module ApplicationHelper
  require 'net/http'

  # API Bodega
  KEY_BODEGA = Rails.application.secrets[:clave_bodega]

  def open_warehouses
    key = KEY_BODEGA
    data = 'GET'
    digest = OpenSSL::Digest.new('sha1')
    hmac = OpenSSL::HMAC.hexdigest(digest, key.encode("ASCII"), data.encode("ASCII"))
    hmac_64 = [[hmac].pack("H*")].pack("m0")
    uri = URI.parse("https://integracion-2018-prod.herokuapp.com/bodega/almacenes")
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "INTEGRACION grupo9:"+hmac_64
    req['Content-Type'] = "application/json"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    res = http.request(req)
    return JSON.parse(res.body)
  end

  def open_products(warehouses)
    key = KEY_BODEGA
    dic = {}
    warehouses.each do |warehouse|
      data = 'GET'+warehouse["_id"]
      digest = OpenSSL::Digest.new('sha1')
      hmac = OpenSSL::HMAC.hexdigest(digest, key.encode("ASCII"), data.encode("ASCII"))
      hmac_64 = [[hmac].pack("H*")].pack("m0")
      uri = URI.parse("https://integracion-2018-prod.herokuapp.com/bodega/skusWithStock?almacenId="+warehouse["_id"])
      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = "INTEGRACION grupo9:"+hmac_64
      req['Content-Type'] = "application/json"
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      res = http.request(req)
      products = JSON.parse(res.body)
      products.each do |product|
        if dic.key?(product["_id"])
          dic[product["_id"]] += product["total"].to_i
        else
          dic[product["_id"]] = product["total"].to_i
        end
      end
    end
    output = []
    dic.keys.each do |sku|
      output << {"sku"=> sku, "available" => dic[sku]}
    end
    return output
  end

  def get_despacho
    warehouses = open_warehouses
    warehouses.each do |warehouse|
      if warehouse["despacho"]
        return warehouse
      end
    end
  end

  def productos_en_despacho
    #HAY QUE FILTRAR LAS ORDENES QUE NO HAYAN SIDO REALIZADAS
    #order = Order.where(state: "creada").first()
    order = {'name'=> 'h32485y813rndh18', 'state'=> 'creada', 'sku'=> '20', 'quantity'=> 100}
    order['state'] = 'aceptada'
    despacho = get_despacho
    almacenes = get_product_on_warehouses([despacho], order['sku'])
    despachados = 0
    data_order = {'sku'=> order['sku'], 'oc'=> order['name'] , 'precioUnitario'=> 5, 'cantidad'=> order['quantity']}
    almacenes.each do |almacenID, productos|
      productos.each do |producto|
        if despachados < order['quantity']
          despachados += 1
        end
      end
    end
    puts 'DESPACHO '+despachados.to_s
    if despachados < order['quantity']
      buscar_productos_almacenes(order,despacho, despachados)
    else
      despachar(producto["productId"], order['name'], 'direccion', precio)
      order['state'] = 'finalizada'
    end
  end

  #PASARLE ORDER, DESPACHO, ENVIADO
  def buscar_productos_almacenes (order, despacho, enviados)
    data_order = {'sku'=> order['sku'], 'oc'=> order['name'] , 'precioUnitario'=> 5, 'cantidad'=> order['quantity']}
    cantidad = order['quantity'] - enviados
    warehouses = open_warehouses
    almacenes = get_product_on_warehouses(warehouses, order['sku'])
    despachados = 0
    almacenes.each do |almacenId, productos|
      if almacenId != despacho['_id']
        productos.each do |producto|
          if despachados < cantidad
            move_to_shop(producto['_id'], despacho['_id'])
            despachados += 1
          end
        end
      end
    end
    puts despachados
    if despachados < cantidad
      faltantes = cantidad - despachados
      fabricar_productos(order, faltantes)
    else
      #despachar(producto["productoId"], order['name'], 'direccion', data_order['precioUnitario']*order['quantity'])
      #order['state'] = 'finalizada'
    end
  end

  #ENTREGA LA CANTIDAD DE PRODUCTOS DE SKU QUE HAY EN ALMACEN DESPACHO DISPONNIBLES
  def buscar_en_despacho(sku, cantidad, orderId)
    despacho = get_despacho
    almacenes = get_product_on_warehouses([despacho], sku)
    en_despacho = 0
    almacenes.each do |almacenID, productos|
      productos.each do |producto|
        if en_despacho < cantidad
          #ver si esta en db, si no esta lo agrega y lo cuenta
          if !((ProductReady.where(productoId: producto["_id"])).exists?)
            new_prod = ProductReady.new(:productoId => producto["_id"], :order_id => orderId)
            new_prod.save
            en_despacho += 1
          end
        end
      end
    end
    return en_despacho
  end

  #RETORNA LA CANTIDAD DE PRODUCTOS QUE MOVIÓ A DESPACHO DEL SKU
  def buscar_en_almacenes(sku, cantidad, orderId)
    despacho = get_despacho
    warehouses = open_warehouses
    almacenes = get_product_on_warehouses(warehouses, sku)
    en_despacho = 0
    almacenes.each do |almacenId, productos|
      if almacenId != despacho['_id']
        productos.each do |producto|
          if en_despacho < cantidad
            if !((ProductReady.where(productoId: producto["_id"])).exists?)
              move_to_shop(producto['_id'], despacho['_id'])
              new_prod = ProductReady.new(:productoId => producto["_id"], :order_id => orderId)
              new_prod.save
              en_despacho += 1
            end
          end
        end
      end
    end
    return en_despacho
  end

  def main_oc
    while (Order.where(check: false).all != 0)
      if Order.where(state: 'WAITING').exists?
        order = Order.where(state: 'WAITING').first()
      elsif Order.where(state: 'STANDBY').exists?
        order = Order.where(state: 'STANDBY').first()
      else
        order = Order.where(state: 'created').first()
      end
      en_despacho = buscar_en_despacho(order.sku, order.quantity, order.name)
      if en_despacho == order.quantity
        despachar_orden(order.name)
      else
        movidos_a_despacho = buscar_en_almacenes(order.sku, order.quantity, order.name)
        if en_despacho + movidos_a_despacho >= order.quantity
          despachar_orden(order.name)
        else
          order.missing = order.quantity - (en_despacho + movidos_a_despacho)
          order.save!
          fabricar_productos(order.sku, order.missing, order)
        end
      end
      order.check = true
      order.save!
    end
    Order.where.not(state: 'finalizada').all do |order|
      order.check = false
      order.save!
    end
  end

  def despachar_orden(orderId)
    order = obtener_oc(orderId)
    direccion = "Fake Street 123"
    while ProductReady.where(order_id: orderId).exists?
      prod = ProductReady.where(order_id: orderId)
      despachar(prod.productoId, orderId, direccion, order['precioUnitario'])
      prod.destroy
    end
    db_order = Order.find(name: orderId)
    db_order.state = 'finalizada'
    order.save!
  end

  def fabricar_productos(sku, cantidad, order)
    recipe = Recipe.find_by(sku: sku)
    puts recipe
    frutas = {"20": recipe.apple, "30": recipe.orange, "40": recipe.strawberry,
      "50": recipe.raspberry, "60": recipe.peach, "70": recipe.blueberry}
    factor = (cantidad/recipe.batch).ceil
    count = 0
    frutas.each do |sku_fruta, fruta|
      if fruta != 0
        fruta_requerida = factor*fruta
        cant_en_despacho = buscar_en_despacho(sku_fruta, fruta_requerida, order.name)
        cant_no_despacho = fruta_requerida - cant_en_despacho
        if cant_no_despacho > 0
          cant_almacenes = buscar_en_almacenes(sku_fruta, cant_no_despacho, order.name)
          cant_faltante = cant_no_despacho - cant_almacenes
          if cant_faltante > 0
            order.state = 'STANDBY'
            order.save!
          else
            count += 1
          end
        else #Si ya está la fruta en despacho
          count += 1
        end
      end
    end
    if count >= recipe.ingredients
      order.state = 'WAITING'
      order.save!
      producir(sku, factor*recipe.batch)
    else
      quitar_reserva_productos(order.name)
    end
  end

  def quitar_reserva_productos(orderId)
    while ProductReady.where(order_id: orderId).exists?
      prod = ProductReady.where(order_id: orderId)
      prod.destroy
    end
  end


  # ----- SPREE HELPERS
  TOKEN = "073cfcc57445bfce201391bcaf913764c18b566f0a1f7480"

  def get_item_id(item_sku)
    uri = URI.parse("http://localhost:3000/api/v1/products")
    req = Net::HTTP::Get.new(uri)
    req['X-Spree-Token'] = TOKEN
    req['Content-Type'] = "application/json"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    res = http.request(req)
    puts "[Spree API]: get_item_id HTTP CODE: "+res.code
    products = JSON.parse(res.body)["products"]
    products.each do |product|
      if product["master"]["sku"].to_i == item_sku.to_i
        return product["master"]["id"]
      end
    end
  end

  # Setea el stock a cantidad q
  def get_stock_by_sku(sku)
    id = get_item_id(sku.to_s)
    uri = URI.parse("http://localhost:3000/api/v1/stock_locations/1/stock_items/"+id.to_s)
    req = Net::HTTP::Get.new(uri)
    req['X-Spree-Token'] = TOKEN
    req['Content-Type'] = "application/json"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    res = http.request(req)
    puts "[Spree API]:get_stock_by_sku HTTP CODE: "+res.code
    json = JSON.parse(res.body)
    return json["count_on_hand"].to_i
  end

  def get_stock_by_id(id)
    uri = URI.parse("http://localhost:3000/api/v1/stock_locations/1/stock_items/"+id.to_s)
    req = Net::HTTP::Get.new(uri)
    req['X-Spree-Token'] = TOKEN
    req['Content-Type'] = "application/json"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    res = http.request(req)
    puts "[Spree API]:get_stock_by_id HTTP CODE: "+res.code
    json = JSON.parse(res.body)
    return json["count_on_hand"].to_i
  end

  def set_stock(sku, q)
    id = get_item_id(sku.to_s)
    uri = URI.parse("http://localhost:3000/api/v1/stock_locations/1/stock_items/"+id.to_s)
    req = Net::HTTP::Put.new(uri)
    req['X-Spree-Token'] = TOKEN
    req['Content-Type'] = "application/json"
    req.body = {stock_item: {count_on_hand: q.to_s, force: true}}.to_json
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    res = http.request(req)
    puts "[Spree API]:set_stock HTTP CODE: "+res.code
  end

  # Aumenta o disminuye el stock en cantidad q (puede ser negativo)
  def vary_stock(sku, q)
    id = get_item_id(sku.to_s)
    uri = URI.parse("http://localhost:3000/api/v1/stock_locations/1/stock_items/"+id.to_s)
    req = Net::HTTP::Put.new(uri)
    req['X-Spree-Token'] = TOKEN
    req['Content-Type'] = "application/json"
    req.body = {stock_item: {count_on_hand: q.to_s}}.to_json
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    res = http.request(req)
    puts "[SPREE API]: vary_stock HTTP CODE: "+res.code
  end

  # ----- API PUBLIC/STOCK

  # Obtiene el json de la Api
  def get_public_stock
    uri = URI.parse("https://api-entrega1ti.herokuapp.com/public/stock")
    req = Net::HTTP::Get.new(uri)
    req['Content-Type'] = "application/json"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    res = http.request(req)
    puts "[API]: get_public_stock HTTP CODE: "+res.code
    return JSON.parse(res.body)
  end

  # API Bodega: Revisa si hay cantidad q del item sku
  def check_stock(sku, q)
    # Ver el stock public
    stock = get_public_stock
    stock.each do |product|
      if product["sku"] == sku.to_s
        if product["available"].to_i >= q.to_i
          return true
        else
          return false
        end
      end
    end
    return false
  end

  def get_api_stock(sku)
    stock = get_public_stock
    stock.each do |product|
      if product["sku"] == sku.to_s
        return product["available"].to_i
      end
    end
  end


end
