module Support
  module RailsEventStore
    def before_setup
      Rails.configuration.event_store =
        ::RailsEventStore::Client.new(repository: RubyEventStore::InMemoryRepository.new)
      super
    end
  end
end

class Minitest::Test
  include Support::RailsEventStore
end
