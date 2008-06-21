ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  RICHARD_FB_ID = "562517137"
  RICHARD_TEST_SESSION_KEY = "7f227a12d49dcc7b89a7e4a7-562517137"

  # kind of like fixtures here these 3 users below
  def get_richard
    fb_user = FacebookerUser.new(RICHARD_FB_ID,"male","Richard", "Jordan",[FacebookerAffiliation.new(1,"UW"),
                                        FacebookerAffiliation.new(2,"Beaux Arts")])
    cr_user1 = User.find_or_create(fb_user.uid, fb_user.sex,
                                fb_user.first_name, fb_user.last_name, fb_user.affiliations)
    cr_user1
  end

  def get_gram
    fb_user = FacebookerUser.new(12345,"female","Gram", "Jordan",[FacebookerAffiliation.new(2,"Beaux Arts")])
    cr_user2 = User.find_or_create(fb_user.uid, fb_user.sex,
                                fb_user.first_name, fb_user.last_name, fb_user.affiliations)
    cr_user2
  end
  def get_mom
    fb_user = FacebookerUser.new(55555,"female","Mom", "Jordan",[FacebookerAffiliation.new(3,"Florida")])
    cr_user3 = User.find_or_create(fb_user.uid, fb_user.sex,
                                fb_user.first_name, fb_user.last_name, fb_user.affiliations)
    cr_user3
  end

  # to trick out facebooker; very important
  def get_params(uid=RICHARD_FB_ID, friends="10701333,10725438,10728457,10730112,575171012,1179772310")
    params = {"fb_sig_time"=>Time.new.to_f.to_s, "_method"=>"GET", "fb_sig_locale"=>"en_US",
        "fb_sig_session_key"=>RICHARD_TEST_SESSION_KEY, "fb_sig_position_fix"=>"1", "fb_sig_in_canvas"=>"1",
        "fb_sig_request_method"=>"GET", "fb_sig_expires"=>"0",
        "fb_sig_friends"=>friends, "fb_sig_added"=>"1",
        "fb_sig_api_key"=>ENV['FACEBOOK_API_KEY'], "fb_sig_profile_update_time"=>"1211485801", 
	"fb_sig_user"=>uid.to_s}
    params.merge!('fb_sig'=>create_fb_sig(params))
    params
  end

    # used to fake out facebooker and get past the filters,
  # but doesn't seem to fake out facebook.com
  def create_fb_sig(params)
    signature = ''
    keys = params.keys.sort
    keys.each do |key|
      next if key == 'fb_sig'
      next unless key.include?('fb_sig')
      key_name = key.gsub('fb_sig_', '')
      signature += key_name
      signature += '='
      signature += params[key]
    end
    signature += ENV['FACEBOOK_SECRET_KEY']
    calculated_sig = Digest::MD5.hexdigest(signature)
    calculated_sig
  end

  # maybe you might like this somewhere,
  # tries to create a real facebooker session but
  # seems to be always invalid for API calls
  def create_session(session_key, fb_id)
    facebook_session = Facebooker::Session.new(ENV['FACEBOOK_API_KEY'], ENV['FACEBOOK_SECRET_KEY'])
    facebook_session.secure_with!(session_key,fb_id,0)
    facebook_session
  end

  # some print methods to debug testing
  def params_print(params)
    puts "params"
    p params.each_pair { |k,v|
                        out =k.to_s + " => " + v.to_s
                        p out
                        }
  end
  def session_print(facebook_session)
    puts "session"
    facebook_session.instance_variables.each { |v|
                                                out = v.to_s + " => " + 
					facebook_session.instance_variable_get(v).to_s
                                                p out      
                                                  }
  end
  def user_print(user)
    puts "user"
    user.instance_variables.each { |v|
                                        out = v.to_s + " => " + user.instance_variable_get(v).to_s
                                        p out
                                  }
  end


  # Do you call these stubs or mocks or whatever?  I'm using them instead of the facebooker's classes
  class FacebookerUser  
    attr_accessor :uid
    attr_accessor :sex
    attr_accessor :first_name
    attr_accessor :last_name
    attr_accessor :affiliations

    def initialize(uid,sex,fname, lname,affiliations)
      @uid = uid
      @sex = sex
      @first_name= fname
      @last_name = lname
      @affiliations=affiliations
    end
  end

  class FacebookerAffiliation
    attr_accessor :nid
    attr_accessor :name
    def initialize(nid, name)
        @nid = nid
        @name = name
    end
  end
end

