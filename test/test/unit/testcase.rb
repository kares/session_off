module Test
  module Unit
    class TestCase < defined?(Minitest::Test) ? Minitest::Test : MiniTest::Unit::TestCase

      {
        :assert_not_empty => :refute_empty,
        :assert_not_equal => :refute_equal,
        :assert_no_match => :refute_match,
        :assert_not_nil => :refute_nil,
      }.each do |tu_name, mt_name|
        alias_method tu_name, mt_name
      end

      def assert_block(msg = nil); assert yield, msg; end

    end
  end
end