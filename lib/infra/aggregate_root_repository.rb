module Infra
  class AggregateRootRepository < AggregateRoot::Repository
    def initialize(event_store = Rails.configuration.event_store)
      super(event_store)
    end
  end
end
