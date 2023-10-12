source "https://rubygems.org"

gem "rails", "~> 7.1.0"
gem "sprockets-rails"
gem "mysql2"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "jbuilder"
gem "redis", ">= 4.0.1"
gem "tzinfo-data", platforms: %i[windows jruby]
gem "bootsnap", require: false
gem "rails_event_store", "~> 2.12.1"

group :development, :test do
  gem "debug", platforms: %i[mri windows]
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "mutant-minitest", "= 0.11.22", require: false
  gem "mutant", "= 0.11.22", require: false
  gem "mutant-license", source: "https://oss:7AXfeZdAfCqL1PvHm2nvDJO6Zd9UW8IK@gem.mutant.dev"
  gem "minitest-ruby_event_store",
      github: "RailsEventStore/rails_event_store",
      glob: "contrib/minitest-ruby_event_store/*.gemspec"
end
