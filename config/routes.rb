Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/public/1234',  to: 'orders#sftp_server'
  get '/public/stock', to: 'products#get_all'
  get '/private/stock', to: 'products#get_all_private'
  get '/despacho', to: 'orders#id_despacho'
end
