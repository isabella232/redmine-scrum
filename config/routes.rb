# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :projects do
  resources :sprints, :shallow => true
  post "sprints/change_task_status",
       :controller => :sprints, :action => :change_task_status,
       :as => :sprints_change_task_status

  resources :product_backlog, :only => [:index, :sort] do
    collection do
      post :sort
    end
  end

end

post "issues/:id/story_points",
     :controller => :scrum, :action => :change_story_points,
     :as => :change_story_points
post "issues/:id/pending_effort",
     :controller => :scrum, :action => :change_pending_effort,
     :as => :change_pending_effort
post "issues/:id/assigned_to",
     :controller => :scrum, :action => :change_assigned_to,
     :as => :change_assigned_to
post "issues/:id/create_time_entry",
     :controller => :scrum, :action => :create_time_entry,
     :as => :create_time_entry
