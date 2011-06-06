require File.expand_path('test_helper', File.dirname(__FILE__))

class SessionOffTest < ActionController::TestCase

  class TestController < ActionController::Base

    session :off, :secure => false, :except => [ :on ],
            :if => Proc.new { |request| ! request.parameters[:force_session] }

    def on
      session[:foo] = 'bar on' if session
      head :ok
    end

    def off
      if session
        session[:foo] = 'bar off'
        head 201
      else
        head 200
      end
    end

    def reset
      reset_session
      head :ok
    end

    def disable_session
      super
      @disable_session = true
    end
    
  end

  tests TestController
  
  setup :save_session_options
  teardown :restore_session_options
  
  test "session is on" do
    get :on
    assert session
    assert_equal 'bar on', session[:foo]
  end

  test "session is off" do
    get :off
    assert_not_equal 'bar off', session[:foo]
    assert_response 200
  end

  test "session is off unless condition met" do
    get :off, :force_session => '1'
    assert_equal 'bar off', session[:foo]
    assert_response 201
  end

  test "session is not reset if off" do
    request.expects(:reset_session).never
    get :reset
  end
  
  test "session is reset if it's on" do
    request.expects(:reset_session).once
    get :reset, :force_session => '1'
  end

  test "request session options are merged" do
    session_options = request.session_options.dup
    begin
      request.session_options[:bar] = 'foo'
      get :on
      assert request.session_options
      assert_equal 'foo', request.session_options[:bar]
    ensure
      request.session_options.clear
      request.session_options.merge!(session_options)
    end
  end
  
  if defined?(ActionController::Base.session_options)
  
    test "global session options are available" do
      session_options = ActionController::Base.session_options.dup
      begin
        ActionController::Base.session_options.merge!({ :domain => ".test.host" })
        get :on
        assert request.session_options
        assert_equal '.test.host', request.session_options[:domain]
      ensure
        ActionController::Base.session_options.replace(session_options)
      end
    end

    test "global session options get merged" do
      session_options = ActionController::Base.session_options.dup
      begin
        ActionController::Base.session_options.merge!({ :secure => true })
        get :on
        assert request.session_options
        assert_equal true, request.session_options[:secure]
      ensure
        ActionController::Base.session_options.replace(session_options)
      end
    end

  end
  
  test "disable session is called when turning session off" do
    get :off
    assert_equal true, @controller.instance_variable_get(:@disable_session)
  end

  test "disable session is not called when session on" do
    get :on
    assert_equal nil, @controller.instance_variable_get(:@disable_session)
  end
  
end
