module OrdersHelper
  require 'net/http'
  KEY_BODEGA = Rails.application.secrets[:clave_bodega]

  def obtener_oc(ocId)
    uri = URI.parse("https://integracion-2018-prod.herokuapp.com/oc/obtener/"+ocId)
    req = Net::HTTP::Get.new(uri)
    req['Content-Type'] = "application/json"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    response = http.request(req)
    puts '[obtener_oc] HTTP CODE: '+response.code
    return JSON.parse(response.body)
  end

  def recepcionar_oc(ocId)
    uri = URI.parse("https://integracion-2018-prod.herokuapp.com/oc/recepcionar/"+ocId)
    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = "application/json"
    req.body = {_id: ocId}.to_json
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    response = http.request(req)
    puts '[recepcionar_oc] HTTP CODE: '+response.code
    return JSON.parse(response.body)
  end

  def rechazar_oc(ocId)
    uri = URI.parse("https://integracion-2018-prod.herokuapp.com/oc/rechazar/"+ocId)
    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = "application/json"
    req.body = {_id: ocId, rechazo: "Rechazo por falta de stock"}.to_json
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    response = http.request(req)
    puts '[rechazar_oc] HTTP CODE: '+response.code
    return JSON.parse(response.body)
  end

  def get_product_on_warehouses(warehouses, sku)
    key = KEY_BODEGA
    output = {}
    warehouses.each do |warehouse|
      data = 'GET'+warehouse["_id"].to_s+sku.to_s
      digest = OpenSSL::Digest.new('sha1')
      hmac = OpenSSL::HMAC.hexdigest(digest, key.encode("ASCII"), data.encode("ASCII"))
      hmac_64 = [[hmac].pack("H*")].pack("m0")
      uri = URI.parse("https://integracion-2018-prod.herokuapp.com/bodega/stock?almacenId="+warehouse["_id"].to_s+"&sku="+sku.to_s)
      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = "INTEGRACION grupo9:"+hmac_64
      req['Content-Type'] = "application/json"
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      res = http.request(req)
      products = JSON.parse(res.body)
      output[warehouse["_id"]] = products
    end
    return output
  end

  def move_to_shop(productoId, almacenId)
    key = KEY_BODEGA
    data = 'POST'+productoId.to_s+almacenId.to_s
    digest = OpenSSL::Digest.new('sha1')
    hmac = OpenSSL::HMAC.hexdigest(digest, key.encode("ASCII"), data.encode("ASCII"))
    hmac_64 = [[hmac].pack("H*")].pack("m0")
    uri = URI.parse("https://integracion-2018-prod.herokuapp.com/bodega/moveStock")
    req = Net::HTTP::Post.new(uri)
    req['Authorization'] = "INTEGRACION grupo9:"+hmac_64
    req['Content-Type'] = "application/json"
    req.body = {productoId: productoId, almacenId: almacenId}.to_json
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    response = http.request(req)
    return JSON.parse(response.body)
  end

  def despachar(productId, oc, direccion, precio)
    key = KEY_BODEGA
    data = 'DELETE'+productId+direccion+precio.to_s+oc
    digest = OpenSSL::Digest.new('sha1')
    hmac = OpenSSL::HMAC.hexdigest(digest, key.encode("ASCII"), data.encode("ASCII"))
    hmac_64 = [[hmac].pack("H*")].pack("m0")
    uri = URI.parse("https://integracion-2018-prod.herokuapp.com/bodega/stock")
    req = Net::HTTP::Post.new(uri)
    req['Authorization'] = "INTEGRACION grupo9:"+hmac_64
    req['Content-Type'] = "application/json"
    req.body = {productoId: productId, oc: oc, direccion: direccion, precio: precio}.to_json
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    response = http.request(req)
    return JSON.parse(response.body)
  end

  def producir(sku, cantidad)
    key = KEY_BODEGA
    data = 'PUT'+sku+cantidad
    digest = OpenSSL::Digest.new('sha1')
    hmac = OpenSSL::HMAC.hexdigest(digest, key.encode("ASCII"), data.encode("ASCII"))
    hmac_64 = [[hmac].pack("H*")].pack("m0")
    uri = URI.parse("https://integracion-2018-prod.herokuapp.com/bodega/fabrica/fabricarSinPago")
    req = Net::HTTP::Put.new(uri)
    req['Authorization'] = "INTEGRACION grupo9:"+hmac_64
    req['Content-Type'] = "application/json"
    req.body = {sku: sku, cantidad: cantidad}.to_json
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    response = http.request(req)
    return JSON.parse(response.body)
  end




  def work
    puts '[DEBUG] called helper.work'
    order = {id: '123spree456puto789'}
    IronmanWorker.perform_async(order[:id])
    sleep 10
  end


end
