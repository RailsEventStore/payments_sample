module Payments
  class Order
    include AggregateRoot

    NOT_SET = Object.new.freeze

    def initialize
      @total_amount = NOT_SET
      @paid_amount = 0
    end

    private attr_accessor :total_amount, :paid_amount

    def request_payment(order_id, amount)
      apply(PaymentRequested.new(data: { order_id: order_id, amount: amount, currency: "EUR" }))
    end

    def register_payment(order_id, amount)
      apply(PaymentRegistered.new(data: { order_id: order_id, amount: amount, currency: "EUR" }))
    end

    def paid?
      return false if total_amount == NOT_SET
      paid_amount >= total_amount
    end

    on PaymentRequested do |event|
      self.total_amount = event.data.fetch(:amount)
    end

    on PaymentRegistered do |event|
      self.paid_amount += event.data.fetch(:amount)
    end
  end
end
