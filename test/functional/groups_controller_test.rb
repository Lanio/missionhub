require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  test "should have permission to see a group in a sub-org" do
    set_up_group_at_sub_org
    get :show, id: @group.id
    assert_response :success
    assert_template :show
  end
  
  test "should be able to create a group in a sub-org" do
    set_up_group_at_sub_org
    get :new
    assert_response :success
    assert_template :new
  end
  
  context "show group details" do
    setup do
      user = Factory(:user_with_auxs)
      sign_in user
      user2 = Factory(:user_with_auxs)
      org = Factory(:organization)
      org.add_leader(user.person, user2.person)
      request.session[:current_organization_id] = org.id
      @group = Factory(:group, organization: org)
    end
    
    should "get show" do
      get :show, :id => @group.id
      assert_response(:success)
    end
  end
  
  context "on index" do
    setup do
      @user, @org = admin_user_login_with_org
      Factory(:group, organization: @org)
    end
    
    should "get index" do
      get :index
      assert_not_nil assigns(:groups)
    end
  end
  
  def set_up_group_at_sub_org
    @user = Factory(:user_with_auxs)
    sign_in @user
    org = Factory(:organization)
    org.add_admin(@user.person)
    @sub_org = Factory(:organization, parent: org, show_sub_orgs: false)
    @group = Factory(:group, organization: @sub_org)
    request.session[:current_organization_id] = @sub_org.id 
  end

end
