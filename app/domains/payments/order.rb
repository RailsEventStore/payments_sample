module Payments
  class Order
    include AggregateRoot

    def request_payment(order_id, amount)
      apply(PaymentRequested.new(data: { order_id: order_id, amount: amount, currency: "EUR" }))
    end

    on PaymentRequested do |_event|

    end
  end
end
