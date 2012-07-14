HireInfluence::Application.routes.draw do
  devise_for :businesses

  devise_for :users, :controllers => { omniauth_callbacks: "users/omniauth_callbacks" }  do
    match 'users/callback' => 'users/omniauth_callbacks#callback'
    match '/users/sign_out' => 'devise/sessions#destroy'
  end

  namespace :users do
    match '/twitter_fillup' => 'users#twitter_fillup', :via=>:post
    match '/profile' => 'profile#index'
    match '/profile_edit' => 'profile#profile_edit'
    match '/update_profile' => 'profile#update_profile'
		match '/unlink' => 'profile#unlink'
  end

  namespace :businesses do
    match '/search' => 'search#index', :via=>:get
    match '/search' => 'search#search', :via=>:post, :as=>:ajax_search
  end


  root :to => "home#index"
end
