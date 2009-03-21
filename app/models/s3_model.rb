require 'logger'

class S3Model

  # get Logger
  @logger = Logger.new(STDOUT)
  
  @config_file = File.join(RAILS_ROOT, 'config/s3_config.yaml')
  
  # bucket_prefix: use this as the prefix for buckets;
  # will be set from bucket_prefix in aws_keys.yaml if defined; otherwise defaults to aws access key
  def self.init(config_file, bucket_prefix=nil)
    config = File.open(@config_file) { |f| YAML::load(f) }
    @aws_access_key = config['aws_access_key']
    @aws_secret_access_key = config['aws_secret_access_key']
    @ssl = config['use_ssl'] || false
    if @ssl
      @logger.debug("SSL is enabled")
    else 
      @logger.debug("SSL is disabled")
    end
    @bucket_prefix = bucket_prefix || config['bucket_prefix'] || @aws_access_key
    @conn = S3::AWSAuthConnection.new(@aws_access_key, @aws_secret_access_key, @ssl)
  end
      
  # lists buckets
  def self.list_buckets
    @conn.list_all_my_buckets.entries
  end
  
  # lists contents of a bucket
  def self.list_bucket(bucket)
    @conn.list_bucket(bucket).entries
  end
  
  # creates a bucket
  def self.create_bucket(bucket)
    @conn.create_bucket(bucket).http_response.message
  end  
  
  # deletes a bucket
  def self.delete_bucket(bucket)
    @conn.delete_bucket(bucket).http_response.message
  end  
    
  # sets ACL to public-read
  def self.set_acl_public_read(bucket, key={})
    if key == {}
      acl_xml = @conn.get_bucket_acl(bucket).object.data
      @logger.debug('--- ACL before ---')
      @logger.debug(acl_xml)
      updated_acl = S3Helper.set_acl_public_read(acl_xml)
      @logger.debug('--- ACL after  ---')
      @logger.debug(updated_acl)
      @logger.debug('------------------')
      @conn.put_bucket_acl(bucket, updated_acl).http_response.message
    else 
      acl_xml = @conn.get_acl(bucket, key).object.data
      @logger.debug('--- ACL before ---')
      @logger.debug(acl_xml)
      updated_acl = S3Helper.set_acl_public_read(acl_xml)
      @logger.debug('--- ACL after  ---')
      @logger.debug(updated_acl)
      @logger.debug('------------------')
      @conn.put_acl(bucket, key, updated_acl).http_response.message
    end
  end

  # sets ACL to private
  def self.set_acl_private(bucket, key={})
    if key == {}
      acl_xml = @conn.get_bucket_acl(bucket).object.data
      @logger.debug('--- ACL before ---')
      @logger.debug(acl_xml)
      updated_acl = S3Helper.set_acl_private(acl_xml)
      @logger.debug('--- ACL after  ---')
      @logger.debug(updated_acl)
      @logger.debug('------------------')
      @conn.put_bucket_acl(bucket, updated_acl).http_response.message
    else 
      acl_xml = @conn.get_acl(bucket, key).object.data
      @logger.debug('--- ACL before ---')
      @logger.debug(acl_xml)
      updated_acl = S3Helper.set_acl_private(acl_xml)
      @logger.debug('--- ACL after  ---')
      @logger.debug(updated_acl)
      @logger.debug('------------------')
      @conn.put_acl(bucket, key, updated_acl).http_response.message
    end
  end

  # deletes a key
  def self.delete_key(bucket, key)
    @conn.delete(bucket, key).http_response.message
  end  
  
  # adds a key
  def self.put_file(bucket, key, data, headers)
    @conn.put(bucket, key, data, headers)
  end
end