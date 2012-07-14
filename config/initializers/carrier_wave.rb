CarrierWave.configure do |config|
  config.fog_credentials = {
      :provider               => 'AWS',       # required
      :aws_access_key_id      => Settings.carrier_wave.amazon_s3.access_key,       # required
      :aws_secret_access_key  => Settings.carrier_wave.amazon_s3.secret_key       # required
      #:region                 => 'eu-west-1'  # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = Settings.carrier_wave.amazon_s3.bucket                    # required
  config.fog_host       = 'http://aws.amazon.com/s3/'            # optional, defaults to nil
  config.fog_public     = false                                   # optional, defaults to true
  #config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end