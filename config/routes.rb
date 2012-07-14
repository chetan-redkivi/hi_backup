HireInfluence::Application.routes.draw do
  devise_for :businesses
  devise_scope :user do
    match 'users/sign_out' => 'devise/sessions#destroy'
    match "/users/callback" => "users/omniauth_callbacks#callback"
  end
  devise_for :users, :controllers => { omniauth_callbacks: "users/omniauth_callbacks" }


  namespace :users do
    match '/twitter_fillup' => 'users#twitter_fillup', :via=>:post
    match '/profile' => 'profile#index'
    match '/profile_edit' => 'profile#profile_edit'
		match '/profile/unlink' => 'profile#unlink'
  end

  namespace :businesses do
    match '/search' => 'search#index', :via=>:get
    match '/search' => 'search#search', :via=>:post, :as=>:ajax_search
  end


  root :to => "home#index"
end
