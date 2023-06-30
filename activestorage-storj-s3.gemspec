# frozen_string_literal: true

require_relative 'lib/active_storage/storj/s3/version'

Gem::Specification.new do |spec|
  spec.name        = 'activestorage-storj-s3'
  spec.version     = ActiveStorage::Storj::S3::VERSION
  spec.authors     = ['Your Data']
  spec.homepage    = 'https://github.com/Your-Data/activestorage-storj-s3'
  spec.summary     = 'activestorage-storj gem extension to provide Storj S3 gateway support'
  spec.description = 'Providing Storj S3 gateway support for activestorage-storj gem'
  spec.license     = 'MIT'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_runtime_dependency 'rails', '~> 7.0', '>= 7.0.4'
  spec.add_runtime_dependency 'aws-sdk-s3', '~> 1.48'
end
