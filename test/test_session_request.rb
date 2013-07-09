require 'securerandom'

module ActionController

  class TestSessionStore < Rack::Session::Abstract::ID

    def initialize(app = nil)
      super(app)
    end

    def get_session(env, sid)
      ( @sessions ||= {} )[sid]
    end

    def set_session(env, sid, session, options)
      ( @sessions ||= {} )[sid] = session
    end

    def destroy_session(env, sid, options)
      ( @sessions ||= {} ).delete(sid)
    end

    public :load_session

  end

  class TestSessionRequest < TestRequest

    def initialize(env = {})
      super

      # self.session = TestSession.new
      # self.session_options = TestSession::DEFAULT_OPTIONS.merge(:id => SecureRandom.hex(16))

      store = TestSessionStore.new
      default_options =
        TestSession::DEFAULT_OPTIONS rescue Rack::Session::Abstract::ID::DEFAULT_OPTIONS
      default_options = default_options.merge(:id => SecureRandom.hex(16))

      if defined? ActionDispatch::Request::Session # 4.x
        session = ActionDispatch::Request::Session.create(store, env, default_options)
        session_options = session.options
      else
        session = TestSession.new
        session_options = default_options
      end

      self.session = session; self.session_options = session_options
    end

  end
end

module TestSessionRequest

  def setup_controller_request_and_response
    @request = ActionController::TestSessionRequest.new
    @response = ActionController::TestResponse.new

    if klass = self.class.controller_class
      @controller ||= klass.new rescue nil
    end

    @request.env.delete('PATH_INFO')

    if defined?(@controller) && @controller
      @controller.request = @request
      @controller.params = {}
    end
  end

end