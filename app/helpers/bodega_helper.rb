module BodegaHelper
  require 'net/http'
  KEY_BODEGA = Rails.application.secrets[:clave_bodega]

  # Recepcion productos (hook)
  def get_webhook
    key = KEY_BODEGA
    data = 'GET'
    digest = OpenSSL::Digest.new('sha1')
    hmac = OpenSSL::HMAC.hexdigest(digest, key.encode("ASCII"), data.encode("ASCII"))
    hmac_64 = [[hmac].pack("H*")].pack("m0")
    uri = URI.parse("https://integracion-2018-prod.herokuapp.com/bodega/hook")
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "INTEGRACION grupo9:"+hmac_64
    req['Content-Type'] = "application/json"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    res = http.request(req)
    return JSON.parse(res.body)["url"]
  end
  def set_webhook
    url = "http://integra9.ing.puc.cl/public/order"
    key = KEY_BODEGA
    data = 'PUT'+url
    digest = OpenSSL::Digest.new('sha1')
    hmac = OpenSSL::HMAC.hexdigest(digest, key.encode("ASCII"), data.encode("ASCII"))
    hmac_64 = [[hmac].pack("H*")].pack("m0")
    uri = URI.parse("https://integracion-2018-prod.herokuapp.com/bodega/hook")
    req = Net::HTTP::Put.new(uri)
    req['Authorization'] = "INTEGRACION grupo9:"+hmac_64
    req['Content-Type'] = "application/json"
    req.body = {url: url}.to_json
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    res = http.request(req)
    return res.code
  end
  def delete_webhook
  key = KEY_BODEGA
  data = 'DELETE'
  digest = OpenSSL::Digest.new('sha1')
  hmac = OpenSSL::HMAC.hexdigest(digest, key.encode("ASCII"), data.encode("ASCII"))
  hmac_64 = [[hmac].pack("H*")].pack("m0")
  uri = URI.parse("https://integracion-2018-prod.herokuapp.com/bodega/hook")
  req = Net::HTTP::Delete.new(uri)
  req['Authorization'] = "INTEGRACION grupo9:"+hmac_64
  req['Content-Type'] = "application/json"
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == "https")
  res = http.request(req)
  return res.code
end
end
