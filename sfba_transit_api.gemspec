Gem::Specification.new do |s|
  s.name        = 'sfba_transit_api'
  s.version     = '1.1.0'
  s.date        = '2014-12-30'
  s.summary     = "SF Bay Area 511 Real-time Transit Data Services API"
  s.description = "San Francisco Bay Area 511 Real-time Transit Data Services API"
  s.authors     = ["Frank Liu"]
  s.email       = 'gniquil@gmail.com'
  s.files       = Dir[ "lib/*.rb", "lib/sfba_transit_api/*.rb" ]
  s.homepage    = 'https://github.com/gniquil/sfba_transit_api'
  s.license       = 'MIT'

  s.add_runtime_dependency "nokogiri", "~> 1.6"
  s.add_runtime_dependency "faraday", "~> 0.9"
  s.add_runtime_dependency "activesupport", "~> 4.1"

  s.add_development_dependency "rspec", "~> 3.1"
  s.add_development_dependency "guard", "~> 2.10"
  s.add_development_dependency "guard-rspec", "~> 4.5"
  s.add_development_dependency "dotenv", "~> 1.0"
end
