def owned_payload_resources(name)
  resources name, only: [:index, :show, :create, :update, :destroy]
  get "#{name}/:name/payload" => "#{name}#payload",
      as: "#{name}_payload",
      constraints: { name: /#{OwnedPayloable.name_regex}/ },
      defaults: { format: :text }
end

Rails.application.routes.draw do
  mount Atmosphere::Engine => "/"

  namespace :admin do
    resources :security_proxies
    resources :security_policies
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      owned_payload_resources :security_proxies
      owned_payload_resources :security_policies
    end
  end
end
