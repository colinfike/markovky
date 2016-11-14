Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :markov do
    collection do
      post 'fetch_twitter_chain'
    end
  end
  
  root 'markov#index'
end
