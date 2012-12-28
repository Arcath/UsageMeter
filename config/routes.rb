UsageMonitor::Application.routes.draw do
  # Resources
  resources :devices
  resources :users
  # Root
  root :to => 'devices#index'
end
