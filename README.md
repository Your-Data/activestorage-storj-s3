# ActiveStorage-Storj-S3
ActiveStorage-Storj-S3 is a ruby gem extension for [activestorage-storj](https://github.com/Your-Data/activestorage-storj) gem to provide [Storj S3 Compatible Gateway](https://docs.storj.io/dcs/api-reference/s3-compatible-gateway) support for some ActiveStorage features, e.g. [direct upload](https://guides.rubyonrails.org/active_storage_overview.html#direct-uploads) which requires [S3 presigned URL](https://docs.storj.io/dcs/api-reference/s3-compatible-gateway/using-presigned-urls).

## Requirements
* [activestorage-storj](https://github.com/Your-Data/activestorage-storj) gem installed in a Rails project.

## Installation
* Add this line to your Rails application's Gemfile:

    ```ruby
    gem 'activestorage-storj-s3', '~> 1.0'
    ```

    And then execute:
    ```bash
    $ bundle install
    ```

* Modify Storj configuration in `config/storage.yml`:

    ```yaml
    storj:
      service: storj_s3   # change from "storj" to "storj_s3"
      ...
      # provide the Storj S3 gateway credentials
      s3_gateway:
        access_key_id: ""
        secret_access_key: ""
        endpoint: ""
        region: global
    ```

  The rest configurations are same as in `activestorage-storj` gem.

## Running the Tests

* Create `configurations.yml` file in `test/dummy/config/environments/service` folder, or copy the existing `configurations.example.yml` as `configurations.yml`.

* Provide Storj configurations for both `storj` and `storj_public` services in `configurations.yml`:

    ```yaml
    storj:
      service: storj_s3
      access_grant: ""
      bucket: ""
      auth_service_address: auth.storjshare.io:7777
      link_sharing_address: https://link.storjshare.io
      s3_gateway:
        access_key_id: ""
        secret_access_key: ""
        endpoint: ""
        region: global

    storj_public:
      service: storj_s3
      access_grant: ""
      bucket: ""
      auth_service_address: auth.storjshare.io:7777
      link_sharing_address: https://link.storjshare.io
      s3_gateway:
        access_key_id: ""
        secret_access_key: ""
        endpoint: ""
        region: global
      public: true
    ```

* Run the tests:

    ```bash
    $ bin/test
    ```
