spec = Gem::Specification.new do |s|
  s.name = 'mezza-testunitxml'
  s.version = '0.1.6'
  s.authors = ['Henrik Mårtensson', "Merul Patel"]
  s.email = ['dag.henrik.martensson@gmail.com', 'merul.patel@gmail.com']
  s.homepage = "https://github.com/mezza/testunitxml"
  s.platform = Gem::Platform::RUBY
  s.summary = "testunitxml extends the Test::Unit framework with an assertion for testing well-formed XML documents."
  s.files = Dir['lib/**/*']
  s.required_ruby_version = '>= 1.8.6'
end