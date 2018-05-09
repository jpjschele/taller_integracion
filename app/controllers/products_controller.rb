class ProductsController < ApplicationController
    skip_before_action :verify_authenticity_token 
    def get_all
        begin
            warehouses = helpers.open_warehouses
            products = helpers.open_products(warehouses)
            render json: products
        rescue
            render :json => {:error => "Internal error"}.to_json, :status => 500
        end

    end
    def income
        render :json => true , :status => 200
    end 

    def get_all_private
        begin
            if request.headers["Authorization"].nil?
                render :json => {:error => "Falta el header Authorization"}.to_json, :status => 400
            else
                if request.headers["Authorization"] == "Bearer Clavegrupo9"
                    warehouses = helpers.open_warehouses
                    products = helpers.open_products(warehouses)
                    render json: products
                else
                    render :json => {:error => "Authenticacion incorrecta"}.to_json, :status => 401
                end  
            end
        rescue
            render :json => {:error => "Internal error"}.to_json, :status => 500
        end
    end
end