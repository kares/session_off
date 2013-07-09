require 'active_support/concern'
require 'active_support/callbacks'

module ActiveSupport
  module Testing

    remove_const :SetupAndTeardown

    module SetupAndTeardown
      
      extend ActiveSupport::Concern

      included do
        include ActiveSupport::Callbacks
        define_callbacks :setup, :teardown

        #if defined?(MiniTest::Assertions) && TestCase < MiniTest::Assertions
          #include ForMiniTest
        #else
          begin
            require 'test/unit/version'
          rescue LoadError
          end unless defined?(Test::Unit::VERSION)
          #if defined?(Test::Unit::VERSION) # Test::Unit 2.x gem
            include ForTestUnit
          #else # "built-in" Test::Unit 1.2.3
            #include ForClassicTestUnit
          #end
        #end
      end

      module ClassMethods
        def setup(*args, &block)
          set_callback(:setup, :before, *args, &block)
        end

        def teardown(*args, &block)
          set_callback(:teardown, :after, *args, &block)
        end
      end

      module ForTestUnit

        # NOTE: mocha (already) does it's Test::Unit#run hook as we do not
        # override the #run method we do not need to worry about mocha here

        def run_setup
          # a lot of rails test code (e.g. from actionpack) depends on this
          # setup order (although it's logically not correct) thus keep it :
          run_callbacks :setup
          super
        end

        def run_teardown
          outcome = super
          run_callbacks :teardown
          outcome
        end

      end

    end
  end
end