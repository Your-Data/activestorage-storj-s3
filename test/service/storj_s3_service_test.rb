# frozen_string_literal: true

require "service/shared_service_tests"

if SERVICE_CONFIGURATIONS[:storj]
  class ActiveStorage::Service::StorjS3ServiceTest < ActiveSupport::TestCase
    SERVICE = ActiveStorage::Service.configure(:storj, SERVICE_CONFIGURATIONS)

    include ActiveStorage::Service::SharedServiceTests

    test "direct upload" do
      key      = SecureRandom.base58(24)
      data     = "Something else entirely!"
      checksum = OpenSSL::Digest::MD5.base64digest(data)
      url      = @service.url_for_direct_upload(key, expires_in: 5.minutes, content_type: "text/plain", content_length: data.size, checksum: checksum)

      uri = URI.parse url
      request = Net::HTTP::Put.new uri.request_uri
      request.body = data
      request.add_field "Content-Type", "text/plain"
      request.add_field "Content-MD5", checksum
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request request
      end

      assert_equal data, @service.download(key)
    ensure
      @service.delete key
    end

    test "direct upload with content disposition" do
      key      = SecureRandom.base58(24)
      data     = "Something else entirely!"
      checksum = OpenSSL::Digest::MD5.base64digest(data)
      url      = @service.url_for_direct_upload(key, expires_in: 5.minutes, content_type: "text/plain", content_length: data.size, checksum: checksum)

      uri = URI.parse url
      request = Net::HTTP::Put.new uri.request_uri
      request.body = data
      @service.headers_for_direct_upload(key, checksum: checksum, content_type: "text/plain", filename: ActiveStorage::Filename.new("test.txt"), disposition: :attachment).each do |k, v|
        request.add_field k, v
      end
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request request
      end

      assert_equal("attachment; filename=\"test.txt\"; filename*=UTF-8''test.txt", @service.s3_bucket.object(key).content_disposition)
      assert_equal("attachment; filename=\"test.txt\"; filename*=UTF-8''test.txt", @service.object(key).custom["content-disposition"])
    ensure
      @service.delete key
    end

    test "directly uploading file larger than the provided content-length does not work" do
      key      = SecureRandom.base58(24)
      data     = "Some text that is longer than the specified content length"
      checksum = OpenSSL::Digest::MD5.base64digest(data)
      url      = @service.url_for_direct_upload(key, expires_in: 5.minutes, content_type: "text/plain", content_length: data.size - 1, checksum: checksum)

      uri = URI.parse url
      request = Net::HTTP::Put.new uri.request_uri
      request.body = data
      request.add_field "Content-Type", "text/plain"
      request.add_field "Content-MD5", checksum
      upload_result = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request request
      end

      assert_equal "403", upload_result.code
      assert_raises ActiveStorage::FileNotFoundError do
        @service.download(key)
      end
    ensure
      @service.delete key
    end
  end
else
  puts "Skipping Storj S3 Service tests because no storj configuration was supplied"
end
