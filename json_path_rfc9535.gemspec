# frozen_string_literal: true

require_relative 'lib/json_path_rfc9535/version'

Gem::Specification.new do |spec|
  spec.name = 'json_path_rfc9535'
  spec.version = JsonPathRfc9535::VERSION
  spec.authors = ['Moku S.r.l.', 'Riccardo Agatea']
  spec.email = ['info@moku.io']
  spec.license = 'MIT'

  spec.summary = 'A Ruby implementation of RFC 9535.'
  spec.description = 'Like XPath is a query language for XML, JsonPath is a query language for JSON. This gem aims ' \
                     'to be an implementation of RFC 9535. Unlike tha original JsonPath description ' \
                     '(http://goessner.net/articles/JsonPath/), RFC 9535 is strictly normative, which ideally should ' \
                     'leave open fewer doors for inconsistencies.'
  spec.homepage = 'https://github.com/moku-io/json_path_rfc9535'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/moku-io/json_path_rfc9535'
  spec.metadata['changelog_uri'] = 'https://github.com/moku-io/json_path_rfc9535/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename __FILE__
  spec.files = IO.popen ['git', 'ls-files', '-z'], chdir: __dir__, err: IO::NULL do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?('bin/', 'test/', 'features/', '.git', 'appveyor', 'Gemfile')
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename f }
  spec.require_paths = ['lib']

  spec.add_dependency 'parslet', '~> 2.0'
end
