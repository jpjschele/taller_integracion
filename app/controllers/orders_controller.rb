  class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token
  require 'net/sftp'
  require 'nokogiri'
  KEY_SFTP = Rails.application.secrets[:clave_sftp]
  KEY_SFTP_DEV = Rails.application.secrets[:clave_sftp_dev]
  def sftp_server
    key = KEY_SFTP
    render :json => true , :status => 200
  end
  def ordenes_de_compra
    
    key = KEY_SFTP_DEV
    Net::SFTP.start('integradev.ing.puc.cl', 'grupo9', :password => key) do |sftp|
      path = '/pedidos'
      sftp.dir.foreach("/pedidos") do |entry|
        sku = ''
        quantity = 0
        id = ''
        state = 'created'
        exists = false
        passed = true
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
              if Order.find_by(:name => id)
                p '[SFTP] order finded'
                exists = true
              end
            elsif node.name == 'sku'
              sku = node.text
            elsif node.name == 'qty'
              quantity = Integer(node.text)
              if quantity > 800
                passed = false
              end
            end
          end
          puts '[SFTP] Order(name: '+id+', sku: '+sku+', qty: '+quantity.to_s+', state: '+state+')'
          unless exists
            # Crear orden en BDD
            new_order = Order.new( :name => id, :state => state, :sku => sku, :quantity => quantity, :missing => quantity, :check => false)
            if new_order.save
              puts '[SFTP] new order saved'
              #sftp.remove("#{path}/#{entry.name}")
              if passed
                puts '[SFTP] new order accepted'
                helpers.recepcionar_oc(id)
              else
                puts '[SFTP] new order rejected'
                helpers.rechazar_oc(id)
              end
            else
              puts '[SFTP] new order NOT saved'
            end
          end
        end
      end
    end

    p '-----------------------'
    p '[SFTP] going to main_oc'
    helpers.main_oc
    return "[SFTP] -------------------------------"
  end

end
