Phaseout::Engine.routes.draw do
  root to: 'phaseout#index'

  get '/actions',            to: 'phaseout#actions',     as: :seo_action_list
  get '/action/:key/keys',   to: 'phaseout#action_keys', as: :seo_action_keys
  get '/fields/:key/update', to: 'phaseout#update',      as: :seo_fields_update
  get '/fields/:key/delete', to: 'phaseout#delete',      as: :seo_fields_delete
end
