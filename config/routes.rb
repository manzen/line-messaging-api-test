Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post '/callback', to: 'line#callback'
    end
  end
end
