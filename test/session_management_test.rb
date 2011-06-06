require File.expand_path('test_helper', File.dirname(__FILE__))

# inspired by Rails 2.2.3's session_management_test !
class SessionManagementTest < ActionController::TestCase # Test::Unit::TestCase

  def setup
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
  end
  
  class SessionOffController < ActionController::Base
    session :off

    def show
      render :text => "done"
    end

    def tell
      render :text => "done"
    end
  end
  
  test 'session_off_globally for action' do
    @controller = SessionOffController.new
    
    get :show
    assert_no_session
  end
  
  test 'session_off_globally for another action' do
    @controller = SessionOffController.new
    
    get :tell
    assert_no_session
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
  
  test 'session_off_globally_then_on for non-matched action' do
    @controller = SessionOffOnController.new
    
    get :show
    assert_no_session
  end

  test 'session_off_globally_then_on for matched action' do
    @controller = SessionOffOnController.new
    
    get :tell
    assert_session
    assert_equal false, @request.session_options[:disabled]
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
  
  test 'controller_specialization_overrides_settings 1' do
    @controller = SpecializedController.new
    
    get :something
    assert_session
  end

  test 'controller_specialization_overrides_settings 2' do
    @controller = SpecializedController.new
    
    get :another
    assert_no_session
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
  
  test 'multiple session offs - off for (non-conditional) action' do
    @controller = TestController.new
    
    get :show
    assert_no_session
  end

  test 'multiple session offs - except (non-conditional) action' do
    @controller = TestController.new
    
    get :tell
    assert_session
    assert @request.session_options[:session_secure]
  end
  
  test 'multiple session offs - on if condition not met' do
    @controller = TestController.new
    
    get :conditional
    assert_session
  end

  test 'multiple session offs - off if condition met' do
    @controller = TestController.new
    
    get :conditional, :ws => "ws"
    assert_no_session
  end
  
  test 'session_is_not_enabled' do
    @controller = TestController.new
    
    get :show
    assert_nothing_raised do
      assert_equal false, @controller.session_enabled?
    end
  end

  test 'session_is_enabled' do
    @controller = TestController.new

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
