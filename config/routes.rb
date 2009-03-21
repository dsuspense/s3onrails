ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Define 100buckets root routed through "test" controller
  map.connect '', :controller => "s3" 

  # Bucket operations
  map.connect '/list_bucket', :controller => "s3", :action => "list_bucket"
  map.connect '/create_bucket', :controller => "s3", :action => "create_bucket"
  map.connect '/delete_bucket', :controller => "s3", :action => "delete_bucket"
  map.connect '/make_bucket_public', :controller => "s3", :action => "make_bucket_public"
  map.connect '/make_bucket_private', :controller => "s3", :action => "make_bucket_private"
  
  # Key operations
  map.connect '/make_key_public', :controller => "s3", :action => "make_key_public"
  map.connect '/make_key_private', :controller => "s3", :action => "make_key_private"
  map.connect '/delete_key', :controller => "s3", :action => "delete_key"
  
  # Upload operations
  map.connect '/upload_file', :controller => "s3", :action => "upload_file"
  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
