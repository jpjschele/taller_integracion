class OrdersController < ApplicationController
    skip_before_action :verify_authenticity_token
    require 'net/sftp'
    require 'nokogiri'

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
        
    end
end
