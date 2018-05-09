class OrdersController < ApplicationController
require 'net/sftp'
require 'nokogiri'

def prueba
    Net::SFTP.start('integradev.ing.puc.cl', 'grupo9', :password => 'kqkgKVqbGBtkbQt') do |sftp|
        # download a file or directory from the remote host
        # f = sftp.file.open("/pedidos/1525674021346.xml")
        # doc = Nokogiri::XML(f) do |config|
        #     config.noblanks
        # end

        # main_node = doc.xpath("//order").first
        # subnode = main_node.children

        # subnode.each do |node|
        #     puts "#{node.text}"
        # end
        sftp.dir.foreach("/pedidos") do |entry|
            if entry == '.' || entry == '..' || entry =='.cache'
                puts entry.name
            end
        end
        
        #sftp.dir.foreach("/pedidos") do |entry|
        #file.open(entry)
        #puts entry.name
end
end
end