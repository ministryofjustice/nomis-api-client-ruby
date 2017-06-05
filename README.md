NOMIS API Client (Ruby)
=======================

A minimal client for the [NOMIS API](http://ministryofjustice.github.io/nomis-api/)

## Installation

### Without bundler

Pre-requisites:
- ruby
- rubygems

```bash
  gem install nomis-api-client  
```

### With bundler

1. In your Gemfile, add:
```ruby
gem 'nomis-api-client'
```

2. From the console:
```bash
bundle install
```

## Usage

### Authentication

The NOMIS API uses JSON Web Token authentication, and requires all requests to provide a Bearer token in the 'Authentication' header. For example:

```bash
Authentication: Bearer eyJ(...rest of big long base64-encoded string removed...)LdRw
```

#### Generating a bearer token automatically

The NOMIS API Client gem can generate a suitable token for you, given your Client Key and Client Token.
You can provide these either directly:

```ruby
  # direct key & token parameters
  NOMIS::API::Get.new(client_key: 'your client key', client_token: 'your client token')
```

or as paths to local files:

```ruby
  # client key & token file parameters
  NOMIS::API::Get.new(client_key_file: 'path to your client key file', client_token_file: 'path to your client token file')
```

or as environment variables:
```bash
  export NOMIS_API_CLIENT_KEY_FILE=/path/to/your/client/key/file
  export NOMIS_API_CLIENT_TOKEN_FILE=/path/to/your/client/token/file
```

#### Specifying an explicit bearer token

If you'd rather provide an explicit token yourself, you can do that as follows:
```ruby
  # explicit auth_token parameter
  NOMIS::API::Get.new(auth_token:'your bearer token')
```

#### Manually generating a bearer token

You can generate a bearer token without making a request as follows:

```ruby
  # Manually generating a bearer token
  NOMIS::API::AuthToken.new(client_key: 'your client key', client_token: 'your client token').bearer_token
```

There is also a command-line executable:

```bash
  generate_bearer_token /path/to/your.token /path/to/your.key
```

### Environment (preprod/prod)

The NOMIS API has two endpoints avaiable:
- production ('prod') at https://noms-api.service.justice.gov.uk/nomisapi/
- pre-production ('preprod') at https://noms-api-preprod.dsd.io/nomisapi/. 

To tell the API client to use one or the other, either provide a base_url parameter:
```ruby
  # direct base_url parameter
  NOMIS::API::Get.new(base_url: 'https://noms-api.service.justice.gov.uk/nomisapi/', ...)
```

or the environment variable NOMIS_API_BASE_URL:
```ruby
  #  base URL environment variable
  export NOMIS_API_BASE_URL='https://noms-api.service.justice.gov.uk/nomisapi/'
```


## Making a request

To make an API request, first construct a Get or Post object, providing:

- path: the path of the endpoint you are requesting (required)

- params: a hash of params you are passing (optional)
- any authentication parameters (optional) - see ['Authentication'](#Authentication) above
- base_url: the base URL (optional) - see ['Environment'](#Environment) above

```ruby
  # construct a 'lookup active offender' request
  req = NOMIS::API::Get.new(path: 'lookup/active_offender', params: {noms_id:'A12345BC', date_of_birth:'1966-05-29'})

  # make the request
  response = req.execute
```

The response will be a ParsedResponse object, encapsulating the raw response, the HTTP status, and the data parsed as JSON:

```ruby
=> #<NOMIS::API::ParsedResponse:0x007ffbf35a1238 @raw_response=#<Net::HTTPOK 200 OK readbody=true>, @data={"found"=>true, "offender"=>{"id"=>1234567}}>

bundle :027 > response.status
 => "200" 

bundle :028 > response.data
 => {"found"=>true, "offender"=>{"id"=>1234567}} 
```

## API Documentation

For full details on the supported endpoints, see the [API documentation](http://ministryofjustice.github.io/nomis-api/)
