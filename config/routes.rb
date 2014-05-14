Paperstencil::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }

  match "a/:address" => "document#instance", :constraints => { :address => /.*/}, via: [:get, :post]

  match "doc/design/create" => "document#design_create", via: [:get, :post]
  get "doc/design/all" => "document#design_list", :as => "user_root"

  post "doc/design/:document_id/title_update" => "document#title_update"
  get "doc/design/:document_id/edit" => "document#design_edit"
  post "doc/design/:document_id/save" => "document#design_save"
  get "doc/design/:document_id/delete" => "document#design_delete"
  post "doc/design/:document_id/share" => "document#share"
  get "doc/design/:document_id/structure" => "document#design_structure"
  get "doc/design/:document_id/pictures" => "document#design_pictures"
  get "doc/design/:document_id/fields" => "document#design_fields"

  get "doc/attachment/:attachment_id" => "file#attachment"
  get "doc/instance/file/:field_instance_id" => "file#serve"


  get "doc/instance/list/:document_id" => "document_instance#list"


  ## Demo login
  get 'demo' => 'demo#login'
  get 'test' => 'demo#test_login'


  get "info/home" => "info#home"
  get "info/pricing" => "info#pricing"
  get "info/tour" => "info#tour"
  get "info/us" => "info#us"
  get "info/tos" => "info#tos"
  get "info/privacy" => "info#privacy"

  root :to => "info#home"

  #match "workflow/all" => "workflow#all"
  #match "workflow/:workflow_id/show" => "workflow#show"
  #match "workflow/:workflow_id/publish" => "workflow#publish"
  #match "workflow/:workflow_id/unpublish" => "workflow#unpublish"
  #match "workflow/:workflow_id/name_update" => "workflow#name_update"
  #match "workflow/:workflow_id/desc_update" => "workflow#desc_update"
  #match "workflow/:workflow_id/delete" => "workflow#delete"

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
