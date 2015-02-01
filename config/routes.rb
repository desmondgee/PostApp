Rails.application.routes.draw do

  # Root
  root "users#index"
  
  # Reports
  get '/city_report' => 'reports#show_activities_by_city', as: :show_activities_by_city

  # Users
  post '/users', :controller=>:users, :action=>:create
  
  # Posts
  get '/posts/:id/links/comments' => 'posts#show_comments', as: :show_post_comments
  get '/posts/*ids' => 'posts#show', as: :show_posts
  put '/posts/*ids' => 'posts#update', as: :update_posts
  delete '/posts/*ids' => 'posts#delete', as: :delete_posts
  get '/posts' => 'posts#index'
  post '/posts' => 'posts#create', as: :create_post
  get '/list_posts/:count' => 'posts#list'
  get '/list_posts' => 'posts#list', as: :list_post
  
  # Comments
  get '/comments' => 'comments#index'
  post '/comments' => 'comments#create', as: :create_comment
  get '/comments/*ids' => 'comments#show', as: :show_comments
  put '/comments/*ids' => 'comments#update', as: :update_comments
  delete '/comments/*ids' => 'comments#delete', as: :delete_comment
  
  # Images
  post '/images' => 'images#create', as: :create_image
  delete '/images/:id' => 'images#delete', as: :delete_image

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
