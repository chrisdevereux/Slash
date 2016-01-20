Pod::Spec.new do |s|
  s.name         = "Slash"
  s.version      = "0.1.4"
  s.summary      = "A simple, extensible, language for styling attributed strings."
  s.description  = <<-DESC
                     A simple, extensible markup language for styling NSAttributedStrings. The language is similar in appearance to HTML, however the tag vocabulary and styles can be easily customized by passing a dictionary argument to the parser.
                    DESC
  s.homepage     = "https://github.com/chrisdevereux/Slash"
  s.license      = { :type => 'MIT', :file => 'LICENCE' }
  s.author       = { "Chris Devereux" => "devereux.chris@gmail.com" }
  s.source       = { :git => "https://github.com/chrisdevereux/Slash.git", :tag => "0.1.4" }
  s.frameworks   = 'CoreText'

  s.ios.deployment_target = '4.3'
  s.osx.deployment_target = '10.6'

  s.public_header_files = 'Slash/Slash.h', 'Slash/SLSMarkupParser.h', 'Slash/SLSErrors.h'
  s.source_files = 'Slash/*.m', 'Slash/*.h'
  s.requires_arc = 'Slash/SLSMarkupParser.m', 'SLSTaggedRange.m'
end
