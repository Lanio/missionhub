require 'test_helper'

class UnsubscribeTest < ActiveSupport::TestCase
  should belong_to(:organization)

  should "have unsubscribe record" do
    @number = '16304182108'
    @survey = Factory(:survey)
    @keyword = Factory(:approved_keyword, survey: @survey)
    @person = Factory.build(:person_without_name)
    @person.save(validate: false)
    @sms_session = Factory(:sms_session, person: @person, sms_keyword: @keyword, phone_number: @number)
    @phone_number = Factory(:phone_number, number: @number)

    @organization = @sms_session.sms_keyword.organization

    unsubscribe = Unsubscribe.new(:phone_number_id => @phone_number.id, :organization_id => @organization.id)
    assert unsubscribe.save
  end
end
