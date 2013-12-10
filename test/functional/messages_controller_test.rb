require 'test_helper'

class MessagesControllerTest < ActionController::TestCase

  setup do
    @user, @org = admin_user_login_with_org
    @contact1 = Factory(:person, phone_number: '445566778', email:'abcd@email.com')
    @contact2 = Factory(:person, phone_number: '112233445', email:'cdef@email.com')
    @org.add_contact(@contact1)
    @org.add_contact(@contact2)
  end

  context "Sent messages " do
    should "return all messages" do
      Messages.create(person_id: @contact1.id, receiver_id: @contact2.id, from: @contact1.email, to: @contact2.email, organization_id: @org.id)
      xhr :post, :sent_messages, {page: 1}
      assert_equal 1, assigns(:messages)
    end
  end

end
