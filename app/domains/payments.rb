module Payments
  PaymentRequested = Class.new(RailsEventStore::Event)
  PaymentRegistered = Class.new(RailsEventStore::Event)
end
