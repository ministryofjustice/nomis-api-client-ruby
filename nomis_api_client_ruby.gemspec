Gem::Specification.new do |s|
  s.name        = 'nomis-api-client'
  s.version     = '0.1.2'
  s.date        = '2017-06-02'
  s.summary     = "Minimal Ruby client for the NOMIS API"
  s.description = "A minimal Ruby client for the [NOMIS API](http://ministryofjustice.github.io/nomis-api/)"
  s.authors     = ["Al Davidson"]
  s.email       = 'alistair.davidson@digital.justice.gov.uk'
  s.files       = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md)
  s.homepage    =
    'http://rubygems.org/gems/nomis_api_client_ruby'
  s.license       = 'MIT'
  s.executables << 'generate_bearer_token'

  s.add_dependency 'jwt'
  s.add_dependency 'openssl'
  
end