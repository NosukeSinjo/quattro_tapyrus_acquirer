Rails.application.routes.draw do
  root 'home#index'
  
  get 'signup', to: 'merchants#new'
  post 'signup', to: 'merchants#create'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get 'payment', to: 'payments#new'
  post 'payment', to: 'payment#create'

  get 'payment/success', to: 'payment#success'
  get 'payment/failure', to: 'payment#failure'
end
