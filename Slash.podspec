Pod::Spec.new do |s|
  s.name         = "Slash"
  s.version      = "0.1"
  s.summary      = "A simple, extensible, language for styling attributed strings."
  s.description  = <<-DESC
                     A simple, extensible markup language for styling NSAttributedStrings. The language is similar in appearance to HTML, however the tag vocabulary and styles can be easily customized by passing a dictionary argument to the parser. 
                    DESC
  s.homepage     = "https://github.com/chrisdevereux/Slash"
  s.license      = { :type => 'MIT', :file => 'LICENCE' }
  s.author       = { "Chris Devereux" => "devereux.chris@gmail.com" }
  s.source       = { :git => "https://github.com/chrisdevereux/Slash.git", :tag => "0.1" }

  s.requires_arc = true

  s.ios.deployment_target = '4.3'
  s.osx.deployment_target = '10.6'

  s.source_files = 'Slash'
  s.public_header_files = 'Slash/Slash.h', 'Slash/SLSMarkupParser.h', 'Slash/SLSErrors.h'

  s.subspec 'no-arc' do |sp|
    sp.source_files = 'Slash/SLSTagParser.m', 'Slash/SLSTagLexer.gen.m', 'Slash/SLSTagParser.gen.m'
    sp.requires_arc = false
  end
end
