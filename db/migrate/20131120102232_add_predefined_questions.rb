class Survey < ActiveRecord::Base; end
class Element < ActiveRecord::Base; end
class SurveyElement < ActiveRecord::Base; end
class AddPredefinedQuestions < ActiveRecord::Migration
  def up
    predefined_survey = Survey.find(APP_CONFIG['predefined_survey'])
    question_faculty = Element.find_by_attribute_name('faculty')
    nationality_faculty = Element.find_by_attribute_name('nationality')
    SurveyElement.find_or_create_by_element_id_and_survey_id(question_faculty.id, predefined_survey.id)
    SurveyElement.find_or_create_by_element_id_and_survey_id(nationality_faculty.id, predefined_survey.id)
  end

  def down
  end
end
