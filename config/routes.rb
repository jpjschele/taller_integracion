Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/public/stock', to: 'products#get_all'
  get '/private/stock', to: 'products#get_all_private'
end
