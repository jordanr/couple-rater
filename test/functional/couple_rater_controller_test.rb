require File.dirname(__FILE__) + '/../test_helper'

include Facebooker::Rails::TestHelpers 
require 'facebooker_publisher.rb'

# We have,
## browse (done)
## rate (done)
## see_globals (done)
## invite_friends (impossible?)
class CoupleRaterControllerTest < ActionController::TestCase
  # network options
  ## chosen
  ## friends
  ## users
  ## anywhere
  ## network_id
  # gender options
  ## bi
  ## gay
  ## lesbian
  ## straight

  ############### TESTING BROWSE ################################
  def test_browse_with_no_params
    Network.delete_all
    User.delete_all

    cr_user1 = get_richard
    
    get :browse, get_params
    assert_response :success

    assert_equal cr_user1, assigns["cr_user"]
    assert_equal "bi", assigns["gender"]
    assert "friends", assigns["network"] 
    assert_equal cr_user1.networks, assigns["nets"]
  end

  def test_browse_with_predefined_couple
    Network.delete_all
    User.delete_all

    cr_user1 = get_richard 
    cr_user2 = get_gram
    coup = Couple.find_or_create(cr_user1.picture.id,cr_user2.picture.id)
       
    get :browse, get_params.merge!({"chosen_picture_id1"=>cr_user1.picture.id, "chosen_picture_id2"=>cr_user2.picture.id, "network"=>"chosen"})
    assert_response :success

    assert flash.empty?
    assert_equal cr_user1, assigns["cr_user"]
    assert_equal "bi", assigns["gender"]
    assert_equal "chosen", assigns["network"]
    assert_equal Network.find(:all), assigns["nets"]
    assert_equal coup.picture1, assigns["couple"].picture1
    assert_equal coup.picture2, assigns["couple"].picture2
    assert_template "couple_rater/browse"
  end

  def test_browse_with_network_param_for_friends_for_user_with_no_friends
    Network.delete_all
    User.delete_all

    cr_user1 = get_richard
    cr_user2 = get_gram
    
    get :browse, get_params(cr_user2.fb_id,"").merge!("network"=>"friends")
    assert_response :success

    assert !flash.empty?
    assert_template nil
    assert_nil assigns["couple"]
    assert_equal cr_user2, assigns["cr_user"]
    assert_equal "bi", assigns["gender"]
    assert "friends", assigns["network"] 
    assert_equal [Network.find_by_network("Beaux Arts")], assigns["nets"]
  end

  def test_browse_with_network_param_for_friends_and_with_more_than_two_friends
    Network.delete_all
    User.delete_all

    cr_user1 = get_richard
    cr_user2 = get_gram
    
    get :browse, get_params.merge!("network"=>"friends")
    assert_response :success

    assert flash.empty?
    assert_template "couple_rater/browse"
    assert_not_nil assigns["couple"]
    assert_equal cr_user1, assigns["cr_user"]
    assert_equal "bi", assigns["gender"]
    assert "friends", assigns["network"] 
    assert_equal Network.find(:all), assigns["nets"]
  end

  def test_browse_with_two_users_and_one_user_with_no_networks_for_anywhere
    Network.delete_all
    User.delete_all

    # user with no networks
    cr_user1 = get_richard
    cr_user2 = get_gram
    cr_user2.networks.clear
    get :browse, get_params(cr_user2.fb_id).merge!(:network=>"anywhere")
    assert !flash.empty?
    assert_template nil
    assert assigns["couple"].nil?
    assert_equal cr_user2, assigns["cr_user"]
    assert "bi", assigns["gender"]
    assert "anywhere", assigns["network"]
    assert_equal [], assigns["nets"]
  end

  def test_browse_with_one_user_for_specified_network
    Network.delete_all
    User.delete_all
    # just one user
    cr_user = get_richard
    net = cr_user.networks.find_by_network("Beaux Arts")
    get :browse, get_params.merge!(:network=>net.id)
    assert_response :success
    # ok what happened?
    assert !flash.empty?
    assert_template nil
    assert assigns["couple"].nil?
    assert_equal cr_user, assigns["cr_user"]
    assert_equal "bi", assigns["gender"]
    assert_equal Network.find_by_network("Beaux Arts").id.to_s, assigns["network"].to_s
    assert_equal Network.find(:all), assigns["nets"]
  end

  def test_browse_with_two_users_with_specified_network
    Network.delete_all
    User.delete_all

    # two users
    cr_user1 = get_richard
    cr_user2 = get_gram
    net = cr_user1.networks.find_by_network("Beaux Arts")
    get :browse, get_params.merge!(:network=>net.id)
    assert_response :success
    # ok what happened?
    assert flash.empty?
    assert_template "couple_rater/browse"
    assert !assigns["couple"].nil?
    if(!assigns["fake_couple"])
      assert_equal cr_user1.picture.couples.first, assigns["couple"]
      assert_equal cr_user2.picture.couples.first, assigns["couple"]
    end
    assert_equal cr_user1, assigns["cr_user"]
    assert_equal "bi", assigns["gender"]
    assert_equal Network.find_by_network("Beaux Arts").id.to_s, assigns["network"]
    assert_equal Network.find(:all), assigns["nets"]
  end
  
  def test_browse_with_two_users_in_different_networks_for_specified_network
    Network.delete_all
    User.delete_all

   # users as only one in network
    cr_user1 = get_richard
    cr_user2 = get_gram
    net = cr_user1.networks.find_by_fb_id(1)
    get :browse, get_params.merge!(:network=>net.id)
    assert !flash.empty?
    assert_template nil
    assert assigns["couple"].nil?
    assert_equal cr_user1, assigns["cr_user"]
    assert_equal "bi", assigns["gender"]
    assert_equal Network.find_by_network("UW").id.to_s, assigns["network"]
    assert_equal Network.find(:all), assigns["nets"]
  end


  def test_browse_with_rating
    Network.delete_all
    User.delete_all

    cr_user1 = get_richard
    cr_user2 = get_gram
    coup = Couple.find_or_create(cr_user1.picture.id,cr_user2.picture.id)
    rat = Rating.create
    coup.ratings << rat
 
    get :browse, get_params.merge!("rating_id"=>rat.id)
    assert_response :success

    assert_equal rat, assigns["rating"]
    assert_equal coup, assigns["last_couple"]
    assert_equal cr_user1, assigns["cr_user"]
    assert_equal "bi", assigns["gender"]
    assert Network.find_by_network("Beaux Arts"), assigns["network"] 
    assert_equal Network.find(:all), assigns["nets"]
    assert !assigns["couple"].nil?
  end

  ####################### END OF TESTING BROWSE #############
  # Now the callback for post messages go to the rate
  # action, which should always redirect back to browse.
  ####################### BEG OF TESTING RATE #############
  def test_rate_with_no_params
    Network.delete_all
    User.delete_all

    cr_user2 = get_richard
       
    post :rate, get_params
    assert_response :success
    assert_template nil
    assert !flash.empty?
  end

  def test_rate_for_network_param_as_friends
    Network.delete_all
    User.delete_all

    cr_user = get_richard

    post :rate, get_params.merge!("network"=>"friends")
    assert_response :success

    assert_template nil
    assert !flash.empty?
  end

  def test_rate_with_rating_and_couple_submitted
    Network.delete_all
    User.delete_all

    cr_user = get_richard
    cr_user2 = get_gram
    coup = Couple.find_or_create(cr_user2.picture.id,cr_user.picture.id)
    assert_equal 0, coup.ratings_sum
    assert_equal 0, coup.ratings_count
   
    if(CoupleRaterController::CREATE_ZERO_RATED_COUPLES)
      post :rate, get_params.merge!("rating"=>10, "couple_id"=>coup.id)
    else
      post :rate, get_params.merge!("rating"=>10, "picture_id1"=>coup.picture1.id, "picture_id2"=>coup.picture2.id)
    end
    assert_response :success

    coup = Couple.find(coup.id)
    assert_equal 10, coup.ratings_sum
    assert_equal 1, coup.ratings_count
    assert_template nil
    assert flash.empty?
  end

  def test_rate_with_rating_and_couple_but_both_are_not_users
    Network.delete_all
    User.delete_all

    cr_user = get_richard
    cr_user2 = get_gram
  
    pic = Picture.find_or_create(0)
    coup = Couple.find_or_create(cr_user.picture.id, pic.id)
    post :rate, get_params.merge!("rating"=>10, "couple_id"=>coup.id)
    assert_response :success

    assert_template nil
    assert !flash.empty?
  end
  def test_rate_with_rating_and_no_couple
    Network.delete_all
    User.delete_all

    cr_user = get_richard

    post :rate, get_params.merge!("rating"=>10)
    assert_response :success

    assert_template nil
    assert !flash.empty?
  end
  def test_rate_with_filter_submit_button
    Network.delete_all
    User.delete_all

    cr_user = get_richard

    post :rate, get_params.merge!("filtersubmit"=>"submit")
    assert_response :success

    assert_template nil
    assert flash.empty?
  end
  ####################### END OF TESTING RATE #############
  # Global stats again does not call the API at all.  And has 
  # no inputs so is easy.
  ####################### BEG OF TESTING SEE GLOBALS #############
  def test_see_globals
    Network.delete_all
    User.delete_all

    cr_user = get_richard

    get :see_globals, get_params
    assert_response :success

    assert_template "couple_rater/see_globals"
    assert flash.empty?
    assert !assigns("newest").nil?
    assert !assigns("recent").nil?
    assert !assigns("rated").nil?
    assert !assigns("highest").nil?
  end
  ####################### END OF TESTING SEE GLOBALS#############
  #
  # INVITE FRIENDS
  ###########################################################
  # impossible right now because we call the 
  # API for friends_with_this_app	
  # Great to try to figure API testing out though
  # because the action is very simple with no logic
  # and just depends on calling the API
  # Should be alright even without testing?
  def test_invite_friends
  #  params = {"auth_token"=>"e5a47132fb5edc5f5f90a276de9c4857"}
  #  facebook_session = create_session(params["fb_sig_session_key"],params["fb_sig_user"])
   # facebook_session.auth_token
#    p facebook_session.user
 #   p facebook_session.user.friends_with_this_app
 #   get :invite_friends, params
  #  assert_response :success
  end    
end
