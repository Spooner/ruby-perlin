require File.expand_path('../lib/perlin/version', __FILE__)

# somewhere in your Rakefile, define your gem spec
Gem::Specification.new do |s|
  s.name = 'perlin'
  s.version = Perlin::VERSION
  s.date = Time.now.strftime '%Y-%m-%d'
  s.authors = ["Brian 'bojo' Jones", 'Camille Goudeseune', 'Bil Bas']

  s.summary = 'Perlin Noise C extension'
  s.description = <<-END
#{s.summary}

A Perlin/Simplex noise implementation based of
<http://freespace.virgin.net/hugo.elias/models/m_perlin.htm>. Implemented as a Ruby C extension.
  END

  s.email = %w<bil.bagpuss@gmail.com mojobojo@gmail.com>
  s.files = Dir.glob %w<CHANGELOG LICENSE Rakefile README.md lib/**/*.{rb,yml} lib ext/**/*.{c,h,rb} examples/**/*.* spec/**/*.*>

  # Only do this while creating a fat binary gem WHEN ON Windows!
  #####s.files << Dir["lib/**/*.so"]

  s.homepage = 'https://github.com/spooner/ruby-perlin'
  s.licenses = %w<MIT>
  s.extensions << 'ext/perlin/extconf.rb'
  s.rubyforge_project = 'ruby-perlin'
  s.test_files = Dir['spec/**/*.*']
  s.has_rdoc = 'yard'

  s.add_development_dependency 'RedCloth', '~> 4.2.9'
  s.add_development_dependency 'yard', '~> 0.8.2.1'
  s.add_development_dependency 'rspec', '~> 2.10.0'
  s.add_development_dependency 'rake-compiler', '~> 0.8.1'
  s.add_development_dependency 'simplecov', '~> 0.6.4'
  s.add_development_dependency 'launchy', '~> 2.1.0'

  # For example.
  s.add_development_dependency 'texplay', '~> 0.4.3'
  s.add_development_dependency 'gosu', '~> 0.7.45'
  s.add_development_dependency 'fidgit', '~> 0.2.4'
end