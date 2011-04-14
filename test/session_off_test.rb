require File.expand_path('test_helper', File.dirname(__FILE__))

=begin
if Rails::VERSION::MAJOR < 3
  ActionController::Routing::Routes.draw do |map|
    map.connect '/:action', :controller => "test"
  end
else
  RequestExceptionHandlerTest::Application.routes.draw do
    match '/:action' => "test"
    #match '/:controller(/:action(/:id))'
  end
end
=end
class SessionOffTest < ActionController::TestCase

  class TestController < ActionController::Base

    session :off, :secure => false,
            :except => [ :on ],
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

  end

  tests TestController

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
    @request.expects(:reset_session).never
    get :reset
  end
  test "session is reset if it's on" do
    @request.expects(:reset_session).once
    get :reset, :force_session => '1'
  end

  test "global session options are available" do
    session_options = ActionController::Base.session_options.dup
    begin
      ActionController::Base.session_options.merge!({ :domain => ".test.host" })
      get :on
      assert @request.session_options
      assert_equal '.test.host', @request.session_options[:domain]
    ensure
      ActionController::Base.session_options.clear
      ActionController::Base.session_options.merge!(session_options)
    end
  end

  test "global session options get merged" do
    session_options = ActionController::Base.session_options.dup
    begin
      ActionController::Base.session_options.merge!({ :secure => true })
      get :on
      assert @request.session_options
      assert_equal true, @request.session_options[:secure]
    ensure
      ActionController::Base.session_options.clear
      ActionController::Base.session_options.merge!(session_options)
    end
  end

end
