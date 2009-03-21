class S3Controller < ApplicationController
  model :s3_model
  
  S3Model.init(@config_file)
  
  # paginate a collection
  def paginate_collection(collection, options = {})
    default_options = {:per_page => 10, :page => 1}
    options = default_options.merge options
    
    pages = Paginator.new self, collection.size, options[:per_page], options[:page]
    first = pages.current.offset
    last = [first + options[:per_page], collection.size].min
    slice = collection[first...last]
    return [pages, slice]
  end
    
  # default controller method
  def index
    if @params[:page] == nil
      @count = 0
      @bucket_page = 1
    else
      @bucket_page = @params[:page]
    end
    @buckets = S3Model.list_buckets
    @entry_pages, @entries = paginate_collection @buckets, { :per_page => 20, :page => @params[:page] }
    @count = (@entry_pages.current.to_i - 1) * 20
  end
  
  # list a bucket
  def list_bucket
    if @params[:page] == nil
      @count = 0
    end
    @bucket_page = @params[:bucket_page]
    @bucket_name = params[:bucket_name]
    @bucket_list = S3Model.list_bucket(@bucket_name)
    @entry_pages, @entries = paginate_collection @bucket_list, { :per_page => 5, :page => @params[:page] }
    @count = (@entry_pages.current.to_i - 1) * 5
  end
  
  # create a bucket
  def create_bucket
    @bucket_name = params[:bucket][:name]
    result = S3Model.create_bucket(@bucket_name)
    logger.debug(result)
    if result == 'OK'
      flash[:notice] = "Bucket '" + @bucket_name + "' successfully created"
    else
      flash[:notice] = "Could not create bucket '" + @bucket_name + "' - Error: " + result
    end
    redirect_to :action => 'index'
  end
  
  # delete a bucket
  def delete_bucket
    @bucket_name = params[:bucket_name]
    result = S3Model.delete_bucket(@bucket_name)
    logger.debug(result)
    if result == 'No Content'
      flash[:notice] = "Bucket '" + @bucket_name + "' successfully deleted"
    else
      flash[:notice] = "Could not delete bucket '" + @bucket_name + "' - Error: " + result
    end
    redirect_to :action => 'index'
  end  

  # make a bucket public
  def make_bucket_public
    @bucket_name = params[:bucket_name]
    S3Model.set_acl_public_read(@bucket_name)
    flash[:notice] = "Set bucket '" + @bucket_name + "' ACL to 'public-read'"
    redirect_to :action => 'index'
  end
  
  # make a bucket private
  def make_bucket_private
    @bucket_name = params[:bucket_name]
    S3Model.set_acl_private(@bucket_name)
    flash[:notice] = "Set bucket '" + @bucket_name + "' ACL to 'private'"
    redirect_to :action => 'index'
  end
  
  # delete a key
  def delete_key
    @bucket_name = params[:bucket_name]
    key = params[:key]
    S3Model.delete_key(@bucket_name, key)
    flash[:notice] = "Deleted item '" + key + "'"
    redirect_to :action => 'list_bucket', :bucket_name => @bucket_name
  end
  
  # make a key public
  def make_key_public
    @bucket_name = params[:bucket_name]
    key = params[:key]
    S3Model.set_acl_public_read(@bucket_name, key)
    flash[:notice] = "Set item '" + key + "' ACL to 'public-read'"
    redirect_to :action => 'list_bucket', :bucket_name => @bucket_name
  end
  
  # make a key private
  def make_key_private
    @bucket_name = params[:bucket_name]
    key = params[:key]
    S3Model.set_acl_private(@bucket_name, key)
    flash[:notice] = "Set item '" + key + "' ACL to 'private'"
    redirect_to :action => 'list_bucket', :bucket_name => @bucket_name
  end
  
  # upload a file
  def upload_file
    @bucket_name = params[:upload][:bucket_name]
    file_to_upload = params[:upload][:filename]
    if file_to_upload == ''
      flash[:notice] = "No upload file specified"
    else    
      base_filename = file_to_upload.original_filename
      file_data = file_to_upload.read
      content_type = file_to_upload.content_type.chomp
      S3Model.put_file(@bucket_name, base_filename, file_data, { 'Content-Type' => content_type })
      flash[:notice] = "Uploaded file '" + base_filename + "'"
    end
    redirect_to :action => 'list_bucket', :bucket_name => @bucket_name
  end
end