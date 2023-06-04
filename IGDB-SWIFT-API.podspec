Pod::Spec.new do |s|
  s.name                  = 'IGDB-SWIFT-API'
  s.version               = '0.4.2'
  s.summary               = 'Wrapper for IGDBs API written in Swift.'
  s.description           = "A Swift wrapper for the IGDB.com Free Video Game Database API."
  s.documentation_url     = "https://api-docs.igdb.com"
  s.homepage              = 'https://github.com/husnjak/IGDB-API-SWIFT'
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.author                = { 'Filip Husnjak' => 'filip@igdb.com' }
  s.source                = { :git => 'https://github.com/husnjak/IGDB-API-SWIFT.git', :tag => s.version.to_s }
  s.platforms             = { :ios => "12.2", :osx => "10.15", :watchos => "7" }
  s.ios.deployment_target = '12.0'
  s.swift_version         = '5.0'
  s.source_files          = 'Sources/IGDB-SWIFT-API/**/*.swift'

s.dependency 'SwiftProtobuf', '~> 1.21.0'
end
