Rails.application.routes.draw do 

  root to: "index#index"


  scope module: 'api', constraints: { format: 'json' } do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      resources :ownerships
      resources :teams, :only=>[:show, :index]
      resources :players, :only=>[:show, :index]
      resources :draft do
        collection do
          post :update_speed
          post :start
          post :pause
          post :restart
          get :feed
        end
      end
    end
  end
end
