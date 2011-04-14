require File.expand_path('test_helper', File.dirname(__FILE__))

# inspired by Rails 2.2.3's session_management_test !
class SessionManagementTest < ActionController::TestCase # Test::Unit::TestCase
  
  class SessionOffController < ActionController::Base
    session :off

    def show
      render :text => "done"
    end

    def tell
      render :text => "done"
    end
  end

  class SessionOffOnController < ActionController::Base
    session :off
    session :on, :only => :tell

    def show
      render :text => "done"
    end

    def tell
      render :text => "done"
    end
  end

  class TestController < ActionController::Base
    session :off, :only => :show
    session :session_secure => true, :except => :show
    session :off, :only => :conditional,
            :if => Proc.new { |r| r.parameters[:ws] }

    def show
      render :text => "done"
    end

    def tell
      render :text => "done"
    end

    def conditional
      render :text => ">>>#{params[:ws]}<<<"
    end
  end

  class SpecializedController < SessionOffController
    session :disabled => false, :only => :something

    def something
      render :text => "done"
    end

    def another
      render :text => "done"
    end
  end


  def setup
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
  end

  def test_session_off_globally
    @controller = SessionOffController.new
    get :show
    assert_no_session
    get :tell
    assert_no_session
  end

  def test_session_off_then_on_globally
    @controller = SessionOffOnController.new
    get :show
    assert_no_session
    get :tell
    assert_session
    assert_equal false, @request.session_options[:disabled]
  end

  def test_session_off_conditionally
    @controller = TestController.new
    get :show
    assert_no_session
    get :tell
    assert_session
    assert @request.session_options[:session_secure]
  end

  def test_controller_specialization_overrides_settings
    @controller = SpecializedController.new
    get :something
    assert_session
    get :another
    assert_no_session
  end

  def test_session_off_with_if
    @controller = TestController.new
    get :conditional
    assert_session
    get :conditional, :ws => "ws"
    assert_no_session
  end

  def test_session_is_enabled
    @controller = TestController.new
    get :show
    assert_nothing_raised do
      assert_equal false, @controller.session_enabled?
    end

    get :tell
    assert @controller.session_enabled?
  end

  private

    def assert_session
      # 2.2.3 behavior :
      # assert_instance_of Hash, @request.session_options
      assert_not_nil @controller.session
    end

    def assert_no_session
      # 2.2.3 behavior :
      # assert_equal false, @request.session_options
      assert_nil @controller.session
    end

end
