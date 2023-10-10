module Support
  module ResAssertions
    def assert_expected_events_in_stream(event_store, expected, stream_name)
      actual =
        event_store
          .read
          .stream(stream_name)
          .map { |event| { data: event.data, type: event.event_type }.with_indifferent_access }
      expected = expected.map { |event| { data: event.data, type: event.class.to_s }.with_indifferent_access }
      assert_equal(expected, actual)
    end
  end
end

class Minitest::Test
  include Support::ResAssertions
end
