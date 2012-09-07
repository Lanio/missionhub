ENV["RAILS_ENV"] = "test"
require 'simplecov'
SimpleCov.start 'rails' do
 add_filter "vendor"
 merge_timeout 36000
end

require File.expand_path('../../config/environment', __FILE__)
require 'rack/oauth2/server'
require 'rails/test_help'
require 'shoulda'
# require 'ephemeral_response'
require 'factory_girl'
require 'api_test_helper'
require File.dirname(__FILE__) + "/factories"
require 'webmock/test_unit'

# EphemeralResponse.activate
# 
# EphemeralResponse.configure do |config|
#   config.fixture_directory = "test/fixtures/ephemeral_response"
#   config.white_list = 'localhost'
# end

#Devise::OmniAuth.test_mode!
OmniAuth.config.test_mode = true
OmniAuth.config.add_mock(:facebook, {"provider"=>"facebook", "uid"=>"690860831", "credentials"=>{"token"=>"164949660195249|bd3f24d52b4baf9412141538.1-690860831|w79R36CalrEAY-9e9kp8fDWJ69A"}, "user_info"=>{"nickname"=>"mattrw89", "email"=>"mattrw89@gmail.com", "first_name"=>"Matt", "last_name"=>"Webb", "name"=>"Matt Webb", "image"=>"http://graph.facebook.com/690860831/picture?type=square", "urls"=>{"Facebook"=>"http://www.facebook.com/mattrw89", "Website"=>nil}}, "extra"=>{"user_hash"=>{"id"=>"690860831", "name"=>"Matt Webb", "first_name"=>"Matt", "last_name"=>"Webb", "link"=>"http://www.facebook.com/mattrw89", "username"=>"mattrw89", "birthday"=>"12/18/1989", "location"=>{"id"=>"108288992526695", "name"=>"Orlando, Florida"}, "education"=>[{"school"=>{"id"=>"115045251844283", "name"=>"Niceville Senior High"}, "year"=>{"id"=>"141778012509913", "name"=>"2008"}, "type"=>"High School"}, {"school"=>{"id"=>"35078114590", "name"=>"University of Central Florida"}, "year"=>{"id"=>"118118634930920", "name"=>"2012"}, "concentration"=>[{"id"=>"124764794262413", "name"=>"Electrical Engineering"}], "type"=>"College"}], "gender"=>"male", "email"=>"mattrw89@gmail.com", "timezone"=>-4, "locale"=>"en_US", "languages"=>[{"id"=>"137946929599946", "name"=>"FORTRAN 66,77"}, {"id"=>"133255596736945", "name"=>"ruby"}, {"id"=>"189887071024044", "name"=>"Objective C"}], "verified"=>true, "updated_time"=>"2011-05-23T12:07:56+0000"}}})
class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :all
  # Add more helper methods to be used by all tests here... 
  Role.admin
  Role.leader
  Role.contact
  Role.involved
end

class ActionController::TestCase
  include Devise::TestHelpers
end

unless defined?(Test::Unit::AssertionFailedError)
  class Test::Unit::AssertionFailedError < ActiveSupport::TestCase::Assertion
  end
end

class TestFBResponses
  FULL = Hashie::Mash.new(ActiveSupport::JSON.decode('{"id":"690860831","name":"Matt Webb","first_name":"Matt","last_name":"Webb","link":"http:\/\/www.facebook.com\/mattrw89","username":"mattrw89","birthday":"12\/18\/1989","location":{"id":"108288992526695","name":"Orlando, Florida"},"education":[{"school":{"id":"1150452518442831","name":"Niceville Senior High"},"year":{"id":"141778012509913","name":"2008"},"type":"High School"},{"school":{"id":"350781145901","name":"University of Central Florida"},"year":{"id":"118118634930920","name":"2012"},"degree":{"id":"12312","name":"Masters"},"concentration":[{"id":"124764794262413","name":"Electrical Engineering"},{"id":"123124124","name":"Underwater Basket Weaving"},{"id":"131212512","name":"Chick Fil A Consumption"}],"type":"College"}],"gender":"male","email":"mattrw89\u0040gmail.com","timezone":-4,"locale":"en_US","languages":[{"id":"137946929599946","name":"FORTRAN 66,77"},{"id":"133255596736945","name":"ruby"},{"id":"189887071024044","name":"Objective C"}],"verified":true,"updated_time":"2011-05-23T12:07:56+0000"}'))
  NO_CONCENTRATION = Hashie::Mash.new(ActiveSupport::JSON.decode('{"id":"690860831","name":"Matt Webb","first_name":"Matt","last_name":"Webb","link":"http:\/\/www.facebook.com\/mattrw89","username":"mattrw89","birthday":"12\/18\/1989","location":{"id":"108288992526695","name":"Orlando, Florida"},"education":[{"school":{"id":"1150452518442832","name":"Niceville Senior High"},"year":{"id":"141778012509913","name":"2008"},"type":"High School"},{"school":{"id":"350781145902","name":"University of Central Florida"},"year":{"id":"118118634930920","name":"2012"},"type":"College"}],"gender":"male","email":"mattrw89\u0040gmail.com","timezone":-4,"locale":"en_US","languages":[{"id":"137946929599946","name":"FORTRAN 66,77"},{"id":"133255596736945","name":"ruby"},{"id":"189887071024044","name":"Objective C"}],"verified":true,"updated_time":"2011-05-23T12:07:56+0000"}'))
  NO_YEAR = Hashie::Mash.new(ActiveSupport::JSON.decode('{"id":"690860831","name":"Matt Webb","first_name":"Matt","last_name":"Webb","link":"http:\/\/www.facebook.com\/mattrw89","username":"mattrw89","birthday":"12\/18\/1989","location":{"id":"108288992526695","name":"Orlando, Florida"},"education":[{"school":{"id":"1150452518442833","name":"Niceville Senior High"},"type":"High School"},{"school":{"id":"350781145903","name":"University of Central Florida"},"year":{"id":"118118634930920","name":"2012"},"concentration":[{"id":"124764794262413","name":"Electrical Engineering"}],"type":"College"}],"gender":"male","email":"mattrw89\u0040gmail.com","timezone":-4,"locale":"en_US","languages":[{"id":"137946929599946","name":"FORTRAN 66,77"},{"id":"133255596736945","name":"ruby"},{"id":"189887071024044","name":"Objective C"}],"verified":true,"updated_time":"2011-05-23T12:07:56+0000"}'))
  WITH_DEGREE = Hashie::Mash.new(ActiveSupport::JSON.decode('{"id":"690860831","name":"Matt Webb","first_name":"Matt","last_name":"Webb","link":"http:\/\/www.facebook.com\/mattrw89","username":"mattrw89","birthday":"12\/18\/1989","location":{"id":"108288992526695","name":"Orlando, Florida"},"education":[{"school":{"id":"1150452518442834","name":"Niceville Senior High"},"year":{"id":"141778012509913","name":"2008"},"type":"High School"},{"school":{"id":"350781145904","name":"University of Central Florida"},"year":{"id":"118118634930920","name":"2012"},"concentration":[{"id":"124764794262413","name":"Electrical Engineering"}],"degree":{"id":"1", "name":"Masters"},"type":"College"}],"gender":"male","email":"mattrw89\u0040gmail.com","timezone":-4,"locale":"en_US","languages":[{"id":"137946929599946","name":"FORTRAN 66,77"},{"id":"133255596736945","name":"ruby"},{"id":"189887071024044","name":"Objective C"}],"verified":true,"updated_time":"2011-05-23T12:07:56+0000"}'))
  NO_EDUCATION = Hashie::Mash.new(ActiveSupport::JSON.decode('{"id":"690860831","name":"Matt Webb","first_name":"Matt","last_name":"Webb","link":"http:\/\/www.facebook.com\/mattrw89","username":"mattrw89","birthday":"12\/18\/1989","location":{"id":"108288992526695","name":"Orlando, Florida"},"gender":"male","email":"mattrw89\u0040gmail.com","timezone":-4,"locale":"en_US","languages":[{"id":"137946929599946","name":"FORTRAN 66,77"},{"id":"133255596736945","name":"ruby"},{"id":"189887071024044","name":"Objective C"}],"verified":true,"updated_time":"2011-05-23T12:07:56+0000"}'))
  FRIENDS = Hashie::Mash.new(ActiveSupport::JSON.decode('{"data":[{"name":"Dan Wiley","id":"1307553"},{"name":"Kris Hodges","id":"2007376"},{"name":"Peter Thompson","id":"2008861"},{"name":"Jason Davis","id":"2044141"},{"name":"Chip Thorn","id":"2057110"},{"name":"Luke Russell","id":"2064076"},{"name":"Shannon Kandt","id":"2322008"},{"name":"James Deyerle","id":"3004566"},{"name":"Kyle Schroeder","id":"4713917"},{"name":"Alana Riley Karl","id":"4916970"},{"name":"Justin Karl","id":"4921067"},{"name":"Daryl Keene","id":"5023163"},{"name":"Brian Dillard","id":"5031505"},{"name":"Nick Sarasty","id":"5103850"},{"name":"Richie Bottinelli","id":"5104099"},{"name":"Ashley Kennard","id":"5104816"},{"name":"Heather Rose","id":"5107234"},{"name":"Rachel Leiter","id":"5107971"},{"name":"David Pezzoli","id":"5108015"},{"name":"Tiffany Bottinelli","id":"5108100"},{"name":"Ryan Weston","id":"5108527"},{"name":"Adam Hill","id":"5108912"},{"name":"Nathan Poole","id":"5110759"},{"name":"Jackson Goss","id":"5113217"},{"name":"Katie Stickle","id":"5114323"},{"name":"Ruth Leppard","id":"5115483"},{"name":"Nathan Harvey","id":"5115553"},{"name":"Shermina Etienne","id":"5116895"},{"name":"Jonathon Defaria","id":"5117180"},{"name":"Russell Kenney","id":"5117508"},{"name":"Katy Hill","id":"5117620"},{"name":"Katie Crabb","id":"5117695"},{"name":"Robin Donnelly","id":"5118811"},{"name":"CW Harrod","id":"5119987"},{"name":"Mario Dipola","id":"5120122"},{"name":"Ben Norris","id":"5120154"},{"name":"Alyssa Marie Aviles","id":"5120286"},{"name":"Nathan Burns","id":"5123253"},{"name":"Katie O\'Connor","id":"5123615"},{"name":"Nick Koutoulas","id":"5123752"},{"name":"Rebekah Clark","id":"5124353"},{"name":"Mike Mage","id":"5124560"},{"name":"Carissa Van Dalen","id":"5124592"},{"name":"Katie Williams","id":"5124697"},{"name":"Iliana Buenrostro","id":"5125516"},{"name":"Alison Helfferich","id":"5125884"},{"name":"Kayla Lyons","id":"5126247"},{"name":"Brian Boyce","id":"5126826"},{"name":"Katrina Los","id":"5127873"},{"name":"Tim Parkin","id":"5127893"},{"name":"Gerin St. Claire","id":"5128590"},{"name":"Becca Ann","id":"5129487"},{"name":"Joshua Spavin","id":"5130011"},{"name":"Paul Schmidt","id":"5130934"},{"name":"Andrew Zeeb","id":"5133211"},{"name":"Nathan Seta","id":"5133727"},{"name":"Kelly Wallace","id":"5133912"},{"name":"Jeff Singer","id":"5134784"},{"name":"Brenna Egan","id":"5134921"},{"name":"Kyle Cox","id":"5135263"},{"name":"Melissa Danger Mage","id":"5135519"},{"name":"Brooke Sams","id":"5136479"},{"name":"Andrew Stoutenburg","id":"5136539"},{"name":"Brandon Smith","id":"5137073"},{"name":"Aviel Solar","id":"5137405"},{"name":"Myles MacCloskey","id":"5137492"},{"name":"Keegan Garcia","id":"5137576"},{"name":"Richie Manis","id":"5137679"},{"name":"Brice E. Gramm","id":"5137997"},{"name":"Marissa Moore","id":"5138042"},{"name":"Katie Lee","id":"5138151"},{"name":"Ericka Ware","id":"5138153"},{"name":"Arthur Chiang","id":"5138428"},{"name":"Geoff Huston","id":"5138633"},{"name":"Eric Hopkins","id":"5139047"},{"name":"Racheal Folowoshele","id":"5139271"},{"name":"Evan Nicolosi","id":"5139816"},{"name":"Sean Curran","id":"5139850"},{"name":"Emily Simpson","id":"5139898"},{"name":"Brandon Keene","id":"5140079"},{"name":"Brian Forfa","id":"5140265"},{"name":"Kevin Eaton","id":"5140343"},{"name":"Stephanie Shafer","id":"5140399"},{"name":"Nick DiDonna","id":"5140463"},{"name":"Sean Martin","id":"5140494"},{"name":"Rene Diaz","id":"5141191"},{"name":"Scott Perdue","id":"5206116"},{"name":"Mike Rapacz","id":"5206366"},{"name":"Drew Hill","id":"5236719"},{"name":"Rachel Rapacz","id":"5236938"},{"name":"Eric Heppner","id":"5237643"},{"name":"Phillip Suderman","id":"5238578"},{"name":"Julia Sander","id":"5252416"},{"name":"Grant DeVuyst","id":"5252560"},{"name":"David Robbins","id":"6517298"},{"name":"Betsy Wolf Bosley","id":"7031655"},{"name":"Arnie Bunch","id":"9431139"},{"name":"Greg Ashworth","id":"12809432"},{"name":"Andrew Ausley","id":"12809886"},{"name":"Ryan Monroe","id":"12821460"},{"name":"Austin Hurd","id":"12821956"},{"name":"Dat Nguyen","id":"13949137"},{"name":"Lauren Lobenhofer","id":"15914112"},{"name":"Tracy Martz","id":"22201843"},{"name":"Nathan Downs","id":"22219957"},{"name":"Shin-Eh Jaimie McGowan","id":"23215238"},{"name":"Lindsay Blair Bean","id":"26510399"},{"name":"Jared Koon","id":"26510747"},{"name":"Michelle Macdonald","id":"26514202"},{"name":"Ali Grace Lovelady","id":"27420127"},{"name":"Krista Miller","id":"28703134"},{"name":"Katie Soehngen","id":"29800126"},{"name":"Mario Martini","id":"31004594"},{"name":"Shelby S Dot Johnson","id":"39115453"},{"name":"Ryan Ballard","id":"39708816"},{"name":"Miranda Graulich","id":"41805113"},{"name":"Leslie Amodeo","id":"44305095"},{"name":"Brandon McKenzie","id":"50102020"},{"name":"Nathan Castleberry","id":"50104592"},{"name":"Eddie Murray","id":"50105881"},{"name":"Matt Spitz","id":"54800642"},{"name":"Jessie Milia","id":"57201315"},{"name":"Heather Felsted","id":"57207140"},{"name":"Marc-Steve Cerniglia","id":"57208718"},{"name":"Erica Lowe","id":"57211092"},{"name":"Peter Gable","id":"57212328"},{"name":"Chris Delph","id":"57213680"},{"name":"Christopher Michael Houston","id":"60605810"},{"name":"Benjamin Warren","id":"60710471"},{"name":"Nasa Sete","id":"65802211"},{"name":"Kaitlyn Simmers","id":"66500737"},{"name":"Christopher Sirico","id":"66502148"},{"name":"Megan Hamner","id":"66503091"},{"name":"Caitlin Pierson","id":"66503930"},{"name":"Hannah Roberts","id":"70701997"},{"name":"Chris Nadolny","id":"71208130"},{"name":"Katie Perdue","id":"75301739"},{"name":"Wayne Nalley","id":"95002011"},{"name":"Patrick Carnathan","id":"100500031"},{"name":"JosephandAngelica Gagliardi","id":"116701093"},{"name":"Brett McCollum","id":"116701506"},{"name":"Rebecca Teague","id":"135000339"},{"name":"Jim Wilder","id":"135000655"},{"name":"Brett Cook","id":"135001171"},{"name":"Katie Williamson","id":"199900920"},{"name":"Nicole Elizabeth Herzig","id":"199900924"},{"name":"Melissa Gagliardi","id":"199900925"},{"name":"Matt Hamner","id":"199900966"},{"name":"Brandon Haugan","id":"199900974"},{"name":"Justin Hubbard","id":"199900990"},{"name":"Juli Dipola","id":"201401121"},{"name":"Goose Prevot","id":"206802212"},{"name":"Josh Starcher","id":"500015648"},{"name":"Phil Thompson","id":"500019726"},{"name":"Eric Crosby","id":"500020399"},{"name":"Mike Thacker","id":"500037447"},{"name":"Aaron Robinson","id":"500038902"},{"name":"Heather Helgeson Nadolny","id":"500039809"},{"name":"Maria Wells Pezzoli","id":"500041664"},{"name":"Lisa Puckey","id":"500041755"},{"name":"Rebecca Hettinger Hodges","id":"500042968"},{"name":"Ross Curtler","id":"500043090"},{"name":"Millie Welsh","id":"500049557"},{"name":"Craig Morrisette","id":"500060687"},{"name":"Jerry Hertzler","id":"500063779"},{"name":"Rich Street","id":"500065394"},{"name":"Dylan Grace","id":"500074660"},{"name":"Kelly Eason Kimberlin","id":"500077407"},{"name":"Daren Ruben","id":"500210684"},{"name":"Ryan Schultz","id":"500294815"},{"name":"John Ortega","id":"500320702"},{"name":"Chris Plekenpol","id":"500395740"},{"name":"Jason Gaskin","id":"500750050"},{"name":"Josh McDorman","id":"500757135"},{"name":"Christopher S Towle","id":"501017759"},{"name":"Jeff Gammons","id":"502124062"},{"name":"Allan Castleberry","id":"502927859"},{"name":"Jeff French","id":"503070847"},{"name":"Noah Seta","id":"503527456"},{"name":"Davis Galleon","id":"503925423"},{"name":"Dan Morrow","id":"504072394"},{"name":"Matty C Pierson","id":"504430395"},{"name":"Mark Whaley","id":"504647361"},{"name":"Wesley Ryan Lynch","id":"504854597"},{"name":"Billy Leister","id":"505342446"},{"name":"Tyler J Fuller","id":"507504872"},{"name":"Ryan Moore","id":"507702129"},{"name":"Christine Doan","id":"507702878"},{"name":"Meg Gieselmann Robbins","id":"507736184"},{"name":"T.J. Van Dam","id":"508324156"},{"name":"Trey Schubert","id":"508460362"},{"name":"Brittany McClintock","id":"508514768"},{"name":"Shiloh Stringer","id":"508560603"},{"name":"Jacob Laughlin","id":"508659063"},{"name":"Justin Koch","id":"509343839"},{"name":"Esther Hsiang","id":"509895407"},{"name":"Nicki Cameron","id":"511456259"},{"name":"Katie Dees","id":"511530584"},{"name":"Megan Cromer","id":"511693474"},{"name":"Danica Van Antwerp","id":"511931145"},{"name":"Felipe Assis","id":"512120180"},{"name":"Whitney Keith","id":"512152632"},{"name":"Lauren Gibson","id":"512321147"},{"name":"Robin Rosado","id":"512638790"},{"name":"Jeannine Smith","id":"512878527"},{"name":"Duane Mays","id":"513557265"},{"name":"Joshua Haley","id":"514140105"},{"name":"Todd Gross","id":"514392571"},{"name":"Veronica Vega","id":"515655318"},{"name":"Alexandria DeYoung","id":"516522589"},{"name":"Tyler David Costley","id":"516648313"},{"name":"Josh Sullivan","id":"517180792"},{"name":"Jillian Southard","id":"517625712"},{"name":"Al\u00ea O\'Czerny","id":"517814909"},{"name":"Chris Clubbs","id":"518473849"},{"name":"Jason Parr","id":"519010189"},{"name":"Bo Duncan","id":"519643031"},{"name":"Emily Rodgers","id":"520218171"},{"name":"Martin Schmidt","id":"520228216"},{"name":"Amber Hoadley","id":"520419347"},{"name":"Patrick Carnahan","id":"520756256"},{"name":"Barrett James Bridgeman","id":"521190188"},{"name":"Patricia Quiroz","id":"521991554"},{"name":"Tim Parsons","id":"524756983"},{"name":"Francesco G. Buzzetta","id":"526105591"},{"name":"Hannah Gibson","id":"528472458"},{"name":"Alan Morell","id":"528724021"},{"name":"Robert McMurtrey","id":"529802873"},{"name":"Jay Marks","id":"533270868"},{"name":"Logan Diaz","id":"533310072"},{"name":"Allison Brelia","id":"533342153"},{"name":"Greg Wance","id":"534112262"},{"name":"Rachael Vega","id":"534471899"},{"name":"Rob Reed","id":"535065137"},{"name":"Gabby Ryan","id":"537313110"},{"name":"Nick Gort","id":"537920407"},{"name":"Joseph Del Rosario","id":"539297963"},{"name":"Mallory Parsons","id":"541077197"},{"name":"Molly Schladenhauffen","id":"542937541"},{"name":"Taylor Short","id":"545871345"},{"name":"Ben Clark","id":"547441421"},{"name":"Dana Ziegler","id":"548063930"},{"name":"Michael Ryan Jones","id":"548177588"},{"name":"Kelly Sue Cox","id":"548269766"},{"name":"Tori Obert","id":"548370465"},{"name":"Ethan King","id":"549134610"},{"name":"Keal Blache","id":"549145816"},{"name":"Whit McClintock","id":"549491338"},{"name":"Dylan Schroeder","id":"549826024"},{"name":"Paul Eastman","id":"549912534"},{"name":"Daniel Grainger","id":"549941359"},{"name":"Wesley Parsons","id":"550306908"},{"name":"Perry Milton","id":"551698494"},{"name":"Isaac Folch","id":"552143386"},{"name":"Marcus Assis","id":"553183105"},{"name":"Chadric Emerson","id":"555276072"},{"name":"Michael Malone","id":"556038312"},{"name":"Evan Lowe","id":"556953622"},{"name":"Michele Leeza Heyman","id":"558706650"},{"name":"Jeffrey Elmore","id":"560422633"},{"name":"Alana Paone Anderson","id":"560722256"},{"name":"Jacqueline Boehme","id":"560793937"},{"name":"Glen Nielsen","id":"561205371"},{"name":"Casey Evers","id":"564020241"},{"name":"Crystal Lenee","id":"564375190"},{"name":"Robert Webb","id":"564631129"},{"name":"Rhyne Harris","id":"564762576"},{"name":"Barry Hosford","id":"565850206"},{"name":"Daryl Smith","id":"565949205"},{"name":"Eric Nachtigal","id":"568777242"},{"name":"Ann Durrenberger","id":"569087840"},{"name":"Nicholas Grant Feran","id":"569236021"},{"name":"Whitney Mayer","id":"569585150"},{"name":"Carlos Felipe Smith","id":"571636728"},{"name":"Nicole Yockey","id":"572084743"},{"name":"Melissa McCown Harrell","id":"572564273"},{"name":"Andrew Cochrum","id":"574486302"},{"name":"Tramica Foster","id":"574782078"},{"name":"Brittany Edwards","id":"578703010"},{"name":"Nelle Burrowes","id":"578972373"},{"name":"Robert Bennett","id":"579116923"},{"name":"Gileah Taylor","id":"579465716"},{"name":"Jonathan Mark Newhall","id":"579870496"},{"name":"Kira Schaafsma","id":"582491895"},{"name":"Courtney Imhoff","id":"583176531"},{"name":"Sam Veatch","id":"585335088"},{"name":"Megan MacEwen","id":"585724408"},{"name":"Joy Nagata","id":"587252570"},{"name":"Brad Rahr","id":"587669953"},{"name":"Antony Stabile","id":"588470355"},{"name":"Jeremy Tomlinson","id":"590561760"},{"name":"Zach Komninos","id":"591353597"},{"name":"Steve Rieske","id":"591845330"},{"name":"Joey Bradshaw","id":"592860885"},{"name":"Billy Russell","id":"592938690"},{"name":"Jason Baker","id":"594221003"},{"name":"Matt Madsen","id":"597277163"},{"name":"Rachel Ronk","id":"597666624"},{"name":"Joshua Nicholson","id":"599763522"},{"name":"Haley Likens","id":"600434466"},{"name":"Kim Cano","id":"600764902"},{"name":"Austin Thompson","id":"603230731"},{"name":"Matthew Whaley","id":"603501060"},{"name":"Dong Pyon","id":"603530729"},{"name":"Albert Manero","id":"603637637"},{"name":"Austin Phillips","id":"604912822"},{"name":"Sarah Lynn Dantzler","id":"607493083"},{"name":"Daniel Silva","id":"609837894"},{"name":"Danielle Steward","id":"612446267"},{"name":"Yesenia Garcia","id":"614353915"},{"name":"Geoff Watson","id":"614601678"},{"name":"Rebecca Deyerle","id":"615950917"},{"name":"Karl Kranich","id":"617168900"},{"name":"Bobby Watson","id":"620873427"},{"name":"Dee Simpson","id":"624425027"},{"name":"Katie Jones","id":"625004250"},{"name":"Kayla Watson","id":"626190773"},{"name":"Shaun Red Bryan","id":"626197904"},{"name":"David Hill","id":"628965447"},{"name":"Paul Williams","id":"629002566"},{"name":"Brandon Thomas","id":"629585028"},{"name":"Catherine Gartrell","id":"630531045"},{"name":"Marc Lowen","id":"631255134"},{"name":"Terry Epps","id":"631487958"},{"name":"Jonathan Richard Tabalanza Bernardo","id":"632993222"},{"name":"Cole Early","id":"633547503"},{"name":"Hope Tuttle","id":"633831210"},{"name":"Robert Bantz","id":"634355625"},{"name":"Tim Fretwell","id":"634771396"},{"name":"Damien F. Brooks","id":"635261419"},{"name":"Lew Wilder","id":"635616674"},{"name":"Bryan Eaton","id":"636129253"},{"name":"Sara Morell","id":"636227813"},{"name":"Jarah Jacquay","id":"636275326"},{"name":"Judy Dickson","id":"636648474"},{"name":"Zachary Moye","id":"636736775"},{"name":"Robby Ronk","id":"637382316"},{"name":"Kevin Thompson","id":"637570195"},{"name":"Robyn Batts","id":"638123882"},{"name":"Linda Clager Wittenberg Linch","id":"638477824"},{"name":"Aven Pitts","id":"639851544"},{"name":"Jake Holmberg","id":"641119421"},{"name":"Rafael Castro","id":"641495529"},{"name":"Sara Elizabeth Powers","id":"643231146"},{"name":"Katie Adams","id":"645246050"},{"name":"David Williams","id":"645816764"},{"name":"Austin McDonald","id":"646155074"},{"name":"Kisa Valenti","id":"646925056"},{"name":"Tanner Teasdale","id":"649192507"},{"name":"Aaron Jordan Henderson","id":"649298898"},{"name":"Holly Siudmak","id":"649443997"},{"name":"Graham Austin","id":"650300426"},{"name":"Amber Scheurer","id":"650594534"},{"name":"Nicole Donaldson","id":"651145943"},{"name":"Diego Cardenas","id":"652040865"},{"name":"Morgan Anderson","id":"655252635"},{"name":"German Andres Melo","id":"655276600"},{"name":"Courtney Marshall","id":"657457447"},{"name":"Ally Castaneda","id":"658795307"},{"name":"James Capelli","id":"659491435"},{"name":"Matt Lavoie","id":"660695223"},{"name":"Jake Hochstadt","id":"662865038"},{"name":"Meghan Suydan","id":"662996602"},{"name":"Chase Sams","id":"663402017"},{"name":"David Barnette","id":"664512779"},{"name":"Maryam Mohd","id":"664812720"},{"name":"Rick Pierson","id":"664934641"},{"name":"Ben Johnson","id":"665444040"},{"name":"Ashley Thania Green","id":"665603100"},{"name":"David A","id":"665770152"},{"name":"Ellen Moore","id":"666977629"},{"name":"Andrew Watson","id":"667104103"},{"name":"John Varghese","id":"668886377"},{"name":"Trey Gordon","id":"670513754"},{"name":"Chris DiDonna","id":"671939523"},{"name":"Sheriffe Oliver","id":"672103065"},{"name":"Jake NumeroUno Trzaskos","id":"672794044"},{"name":"Victoria Baxter","id":"672880524"},{"name":"Patrick Carlton","id":"673206881"},{"name":"Lloyd Wickboldt","id":"674853759"},{"name":"Matt Lind","id":"675402028"},{"name":"Amber J Phillips","id":"675594798"},{"name":"Erika Victoria Dane","id":"675649788"},{"name":"Nate Ward","id":"675729051"},{"name":"Alex Melvin","id":"676566018"},{"name":"Jacquelyn Babe","id":"677070849"},{"name":"Donna Dearman Pierson","id":"677584048"},{"name":"Trey Mansfield","id":"681343473"},{"name":"Nick Banks","id":"681983209"},{"name":"Naty Cardenas","id":"683301009"},{"name":"Joseph Smales","id":"684643352"},{"name":"Callie Pitman","id":"685445191"},{"name":"Rebecca Bennett","id":"686311742"},{"name":"Zachariah A Glotfelty","id":"686685426"},{"name":"Sarah Lyn Schmidt","id":"687246306"},{"name":"Emily Alexandra Conroyd","id":"687485805"},{"name":"Samuel Jackson Hays IV","id":"687635573"},{"name":"Kyra Candell Speegle","id":"688342843"},{"name":"Joshua Alec Samac","id":"688793973"},{"name":"Amy Simpson","id":"689310407"},{"name":"Henry Cabrera","id":"690055461"},{"name":"Anthony Mello","id":"691805011"},{"name":"Amie Sprague","id":"692309273"},{"name":"Chucky Manning","id":"692521599"},{"name":"Alexandra Hope Scerbo","id":"692821058"},{"name":"Caleb Gross","id":"695275937"},{"name":"Cory Christoffer","id":"695324022"},{"name":"Katie Wilson","id":"695885400"},{"name":"Emily Victoria Schock","id":"695911244"},{"name":"Robbie Amend","id":"696241198"},{"name":"Jennifer Black","id":"696377515"},{"name":"Ryan Broder","id":"1438375467"},{"name":"Jean Weatherwax","id":"1440139301"},{"name":"Luke Ausley","id":"1441243491"},{"name":"Jacob Baltz","id":"1441458244"},{"name":"Jonathan Pearson","id":"1443497166"},{"name":"Mark Penner","id":"1443965166"},{"name":"Nick Clark","id":"1445950513"},{"name":"Tyler Ellis","id":"1447035118"},{"name":"Evan Lederman","id":"1450891168"},{"name":"Cody Fliehman","id":"1463415394"},{"name":"Tyler Provost","id":"1467585090"},{"name":"Nick Williams","id":"1475065404"},{"name":"Mary Davenport-Sirico","id":"1480545156"},{"name":"Dan Anderson","id":"1481177475"},{"name":"Rurel Ausley","id":"1494039008"},{"name":"Yansey Lane Wilson","id":"1495549280"},{"name":"Matthew Cloyd","id":"1496435417"},{"name":"Mark Applegate","id":"1497083477"},{"name":"Maggie Graham","id":"1500180116"},{"name":"Steven Calhoun","id":"1502323506"},{"name":"Michael Christakos","id":"1504866961"},{"name":"Emma SportySpice Holmes","id":"1507980012"},{"name":"Anthony Snodgrass","id":"1511370152"},{"name":"Samantha Sementilli","id":"1519121746"},{"name":"Adam Mills","id":"1534631856"},{"name":"Liliana Caldero","id":"1536822061"},{"name":"Kiersten Bradley","id":"1543040710"},{"name":"Caleb Pearson","id":"1543147835"},{"name":"Annie Pearson","id":"1543594922"},{"name":"Jeff Trimble","id":"1546680127"},{"name":"Katie Lay","id":"1551360043"},{"name":"Maxwell Fletcher","id":"1554471584"},{"name":"Jessica Jamie","id":"1555422924"},{"name":"Drew Nuti","id":"1572451249"},{"name":"Brian Parkhurst","id":"1572857906"},{"name":"Shelley Dean Weeks","id":"1579016746"},{"name":"Linda Hague","id":"1580868053"},{"name":"Eric Mullins","id":"1593030278"},{"name":"Timothy Farris","id":"1594051165"},{"name":"Christopher Seul","id":"1597050579"},{"name":"Michael E Nixon","id":"1598004649"},{"name":"Tyler Ewing","id":"1598827333"},{"name":"Graeme Phillip","id":"1600860070"},{"name":"Ryan Hill","id":"1601370696"},{"name":"Cody Theriot","id":"1607768372"},{"name":"Joey Pabst","id":"1618855324"},{"name":"Mike Williams","id":"1620094501"},{"name":"Corey Palmer","id":"1620520764"},{"name":"Andrew Griffin","id":"1623904063"},{"name":"Kella Bella","id":"1625434029"},{"name":"Lance Preston","id":"1626545838"},{"name":"Eddie Steadman","id":"1628000441"},{"name":"Nick Jenkins","id":"1636360174"},{"name":"Joshua Linge","id":"1636898939"},{"name":"Josh Allen","id":"1643793452"},{"name":"Ian Kessler","id":"1676580122"},{"name":"Bailey Logan","id":"1682237495"},{"name":"Jamer Elder","id":"1684170035"},{"name":"Spencer DeWald","id":"1689300123"},{"name":"Johnny Schuler","id":"1693497627"},{"name":"Jessica Collier","id":"1700445348"},{"name":"Tom Sprague","id":"1718998227"},{"name":"Eric Jose Jostad","id":"1731688190"},{"name":"Moses McKnight","id":"1737402490"},{"name":"Nick Harvey","id":"1782732609"},{"name":"Emily Foca","id":"1793060020"},{"name":"Scott Walton","id":"1794150048"},{"name":"Lloyd Harrison","id":"1800053794"},{"name":"Ian Cooke","id":"1819908587"},{"name":"Gabriel Willman","id":"100000003350740"},{"name":"Grant Arnold","id":"100000015918600"},{"name":"Hunter Wilkins","id":"100000033884695"},{"name":"Jessica Ida Tilosius Sandlin","id":"100000039970826"},{"name":"Phillip Ten Eyck","id":"100000072601627"},{"name":"James Bradbury","id":"100000104911399"},{"name":"Bret Helton","id":"100000109881197"},{"name":"Mike Milchling","id":"100000159643169"},{"name":"Mark Fling","id":"100000213960998"},{"name":"Jill Cromer","id":"100000226376058"},{"name":"Juan Gabriel Quevedo","id":"100000241313336"},{"name":"Will Anderson","id":"100000247675121"},{"name":"Juleene Hasty","id":"100000267967319"},{"name":"Ward Silverman","id":"100000271164088"},{"name":"Phil Smith","id":"100000279403585"},{"name":"Fred Teutenberg","id":"100000291050183"},{"name":"Mary Smith","id":"100000325446456"},{"name":"Michael Edan Cummings","id":"100000368851838"},{"name":"Dwayne Roane","id":"100000393435247"},{"name":"Robert Young","id":"100000447371366"},{"name":"Matt Beattie","id":"100000500027838"},{"name":"Matthew Underwood","id":"100000526633394"},{"name":"Amanda Gonzalez","id":"100000574818248"},{"name":"Joseph TheSailor Jackson","id":"100000593437511"},{"name":"Ashley Tankersley","id":"100000675420859"},{"name":"Robyn Riddle","id":"100000781590028"},{"name":"Jane Vega","id":"100001061318938"},{"name":"Molly Creek","id":"100001086848273"},{"name":"Brittany Berryman","id":"100001093509603"},{"name":"Christopher Sandlin","id":"100001170896898"},{"name":"Drew Gadson","id":"100001198383106"},{"name":"Darren Martin","id":"100001213736006"},{"name":"Msp Pictures","id":"100001225682493"},{"name":"Jordan Chambers","id":"100001277030709"},{"name":"Rene Gonzalez","id":"100001505364623"},{"name":"John Mear-Bear","id":"100001775958752"},{"name":"Kelsey Martin","id":"100001872228407"},{"name":"Anthony Taveras","id":"100001892698001"},{"name":"Miller Hederi","id":"100002250185942"}]}'
  ))
  INTERESTS = Hashie::Mash.new(ActiveSupport::JSON.decode('{"data":[{"name":"Music","category":"Field of study","id":"112936425387489","created_time":"2010-04-23T17:34:48+0000"},{"name":"Jesus","category":"Public figure","id":"104332632936376","created_time":"2010-04-23T17:34:48+0000"}]}'))
end


def admin_user_login_with_org
  @user = Factory(:user_with_auxs)
  @org = @user.person.organizations.first
  
  @request.session[:current_organization_id] = @org.id
  
  sign_in @user
  return @user, @org
end
