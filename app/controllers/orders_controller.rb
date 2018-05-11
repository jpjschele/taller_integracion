class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token
  require 'net/sftp'
  require 'nokogiri'
  key = 'NTMFwkt1:e$A&m'
  
def sftp_server
    render :json => true , :status => 200
    Net::SFTP.start('integradev.ing.puc.cl', 'grupo9', :password => 'kqkgKVqbGBtkbQt') do |sftp|
        path = '/pedidos'
        sftp.dir.foreach("/pedidos") do |entry|
            sku = ''
            quantity = 0
            id = ''
            estado = 'created'
            passed = 0
            if entry.name != '.' && entry.name != '..' && entry.name !='.cache'
                file = sftp.file.open("#{path}/#{entry.name}")
                doc = Nokogiri::XML(file) do |config|
                        config.noblanks
                    end
                    main_node = doc.xpath("//order").first
                    subnode = main_node.children
                    subnode.each do |node|
                        if node.name == 'id'
                            id = node.text
                        end
                        if node.name == 'sku'
                            sku = node.text
                        end
                        if node.name == 'qty'
                            quantity = Integer(node.text)
                            passed = 1
                            end
                        end
                    end
                    
                    if passed == 1
                        new_order = Order.new( :order => id, :estado => estado, :sku => sku, :quantity => quantity)
                        new_order.save
                        sftp.remove("#{path}/#{entry.name}")
                    end
            end
        end

        #sftp.dir.foreach("/pedidos") do |entry|
        #file.open(entry)
        #puts entry.name
end
end

  def get_product_on_warehouses(warehouses, sku)
    output = []
    warehouses.each do |warehouse|
      data = 'GET5ad36a2dd6ed1f00049c2f6b20'
      digest = OpenSSL::Digest.new('sha1')
      hmac = OpenSSL::HMAC.hexdigest(digest, key.encode("ASCII"), data.encode("ASCII"))
      hmac_64 = [[hmac].pack("H*")].pack("m0")
      uri = URI.parse("https://integracion-2018-dev.herokuapp.com/bodega/stock?almacenId=5ad36a2dd6ed1f00049c2f6b&sku=20")
      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = "INTEGRACION grupo9:"+hmac_64
      req['Content-Type'] = "application/json"
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      res = http.request(req)
      products = JSON.parse(res.body)

      info = []
      products.each do |product|
        if product["sku"] == "20"
          info << {"cantidad"=> 8, "sku"=> sku}
        end
      end
      output << {"almacenId"=> warehouse["_id"], "recepcion"=> warehouse["recepcion"],
      "despacho"=> warehouse["despacho"], "pulmon"=> warehouse["pulmon"],
      "products"=> info}
    end
    return products
  end

  def move_to_shop(productId, almacenId)
    data = 'POST'+productId+almacenId
    digest = OpenSSL::Digest.new('sha1')
    hmac = OpenSSL::HMAC.hexdigest(digest, key.encode("ASCII"), data.encode("ASCII"))
    hmac_64 = [[hmac].pack("H*")].pack("m0")
    uri = URI.parse("https://integracion-2018-dev.herokuapp.com/bodega/moveStock")
    header = {}
    header['Authorization'] = "INTEGRACION grupo9:"+hmac_64
    header['Content-Type'] = "application/json"
    bod = {}
    bod['productoId'] = productId
    bod['almacenId'] = almacenId
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = bod.to_json
    response = http.request(request)

    return response
  end

  # def get_quantity()
  #   dic = {}
  #   warehouses.each do |warehouse|
  #     data = 'GET'+warehouse["_id"]
  #     digest = OpenSSL::Digest.new('sha1')
  #     hmac = OpenSSL::HMAC.hexdigest(digest, key.encode("ASCII"), data.encode("ASCII"))
  #     hmac_64 = [[hmac].pack("H*")].pack("m0")
  #     uri = URI.parse("https://integracion-2018-dev.herokuapp.com/bodega/skusWithStock?almacenId="+warehouse["_id"])
  #     req = Net::HTTP::Get.new(uri)
  #     req['Authorization'] = "INTEGRACION grupo9:"+hmac_64
  #     req['Content-Type'] = "application/json"
  #     http = Net::HTTP.new(uri.host, uri.port)
  #     http.use_ssl = (uri.scheme == "https")
  #     res = http.request(req)
  #     products = JSON.parse(res.body)
  #     products.each do |product|
  #         if dic.key?(product["_id"])
  #             dic[product["_id"]] += product["total"].to_i
  #         else
  #             dic[product["_id"]] = product["total"].to_i
  #         end
  #     end
  #
  #   end
  #   output = []
  #   dic.keys.each do |sku|
  #       output << {"sku"=> sku, "available" => dic[sku]}
  #   end
  #   return output
  # end

  def despachar(productId, oc, direccion, precio)
    data = 'DELETE'+productId+direccion+precio+oc
    digest = OpenSSL::Digest.new('sha1')
    hmac = OpenSSL::HMAC.hexdigest(digest, key.encode("ASCII"), data.encode("ASCII"))
    hmac_64 = [[hmac].pack("H*")].pack("m0")
    uri = URI.parse("https://integracion-2018-dev.herokuapp.com/bodega/stock")
    header = {}
    header['Authorization'] = "INTEGRACION grupo9:"+hmac_64
    header['Content-Type'] = "application/json"
    bod = {}
    bod['productoId'] = productId
    bod['oc'] = oc
    bod['direccion'] = direccion
    bod['precio'] = precio
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = bod.to_json
    response = http.request(request)

    return response
  end

end
