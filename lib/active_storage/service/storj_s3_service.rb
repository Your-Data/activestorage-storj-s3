# frozen_string_literal: true

require "active_storage/service/storj_service"
require "aws-sdk-s3"

module ActiveStorage
  class Service::StorjS3Service < Service::StorjService
    class S3GatewayConfigRequiredError < ActiveStorage::Error; end

    attr_reader :s3_bucket

    def initialize(access_grant:, bucket:, upload_chunk_size: nil, download_chunk_size: nil, multipart_upload_threshold: nil,
      auth_service_address: nil, link_sharing_address: nil, public: false, **config)
      super(access_grant: access_grant, bucket: bucket, upload_chunk_size: upload_chunk_size, download_chunk_size: download_chunk_size,
        multipart_upload_threshold: multipart_upload_threshold, auth_service_address: auth_service_address, link_sharing_address: link_sharing_address,
        public: public, **config)

      s3_config = config[:s3_gateway]
      raise S3GatewayConfigRequiredError.new, "S3 Gateway configuration is required" if s3_config.blank?

      @s3_client = Aws::S3::Resource.new(
        access_key_id: s3_config[:access_key_id],
        secret_access_key: s3_config[:secret_access_key],
        region: s3_config[:region],
        endpoint: s3_config[:endpoint]
      )
      @s3_bucket = @s3_client.bucket(bucket)

      upload = s3_config[:upload] || {}
      @s3_upload_options = upload
      @s3_upload_options[:acl] = "public-read" if public?
    end

    def url_for_direct_upload(key, expires_in:, content_type:, content_length:, checksum:, custom_metadata: {})
      instrument :url, key: key do |payload|
        generated_url = @s3_bucket.object(key).presigned_url :put, expires_in: expires_in.to_i,
          content_type: content_type, content_length: content_length, content_md5: checksum,
          metadata: custom_metadata, whitelist_headers: ["content-length"], **@s3_upload_options

        payload[:url] = generated_url

        generated_url
      end
    end
  end
end
