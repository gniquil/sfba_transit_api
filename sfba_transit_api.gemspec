Gem::Specification.new do |s|
  s.name        = 'sfba_transit_api'
  s.version     = '0.1.0'
  s.date        = '2014-12-30'
  s.summary     = "San Francisco Bay Area 511 Real-time Transit Data Services API"
  s.description = "A Simple Way to Query the 511 RTT API"
  s.authors     = ["Frank Liu"]
  s.email       = 'gniquil@gmail.com'
  s.files       = Dir[ "lib/*.rb", "lib/sfba_transit_api/*.rb" ]
  s.homepage    = 'https://github.com/gniquil/sfba_transit_api'
  s.license       = 'MIT'

  s.add_runtime_dependency "nokogiri"
  s.add_runtime_dependency "faraday"
  s.add_runtime_dependency "activesupport"

  s.add_development_dependency "rspec"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "dotenv"
end
