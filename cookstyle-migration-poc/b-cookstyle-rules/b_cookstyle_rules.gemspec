# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'b_cookstyle_rules'
  spec.version       = '1.0.0'
  spec.authors       = ['Barclays Infrastructure Team']
  spec.email         = ['chef-pipeline@barclays.com']

  spec.summary       = 'Custom Cookstyle cops for Barclays Chef cookbook compliance'
  spec.description   = 'Organization-specific Cookstyle/RuboCop cops migrated from Foodcritic BARC rules'
  spec.homepage      = 'https://github.barclays.com/chef/b-cookstyle-rules'
  spec.license       = 'Proprietary'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.require_paths = ['lib']

  # Dependencies
  spec.add_dependency 'rubocop', '>= 1.25.0'
  spec.add_dependency 'cookstyle', '>= 7.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
