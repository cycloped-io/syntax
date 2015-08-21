Gem::Specification.new do |s|
  s.name = "cyclopedio-syntax"
  s.version = "0.1.0"
  s.date = "#{Time.now.strftime("%Y-%m-%d")}"
  s.required_ruby_version = '>= 2.0.0'
  s.authors = ['Krzysztof Wrobel', 'Aleksander Smywiński-Pohl']
  s.email   = ['djstrong@gmail.com', 'apohllo@o2.pl']
  s.homepage    = "http://github.com/cycloped-io/syntax"
  s.summary = "English syntax manipulation for cycloped.io"
  s.description = "Library for manipulating sentence parses produced by Stanford NLP and similar tools used to manipulate English Wikipedia category names"

  s.rubyforge_project = "cyclopedio-syntax"
  s.rdoc_options = ["--main", "Readme.md"]

  s.files         = `git ls-files .`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = "lib"

  s.add_dependency("rubytree")
end

