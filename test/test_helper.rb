ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

require "mutant/minitest/coverage"
require "support/res_assertions"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    fixtures :all

    def event_store
      Rails.configuration.event_store
    end
  end
end
