require File.dirname(__FILE__) + '/../test_helper'

# We have,
## see_matches (done)
## filter_matches (in progress)
## see_friends (impossible?)
## see_pictures (impossible?)
## change_picture
## see_privacy
## change_privacy
## see_networks (impossible?)
## change_networks (impossible?)

class UsersControllerTest < ActionController::TestCase
  
  # See matches is a monster page like browse so
  # this testing is pretty thick
  ############# TESTING SEE MATCHES ###############
  def test_see_matches_with_no_params
    Network.delete_all
    User.delete_all
    # just one user
    cr_user = get_richard

    get :see_matches, get_params
    assert_response :success

    # ok what happened?
    assert flash.empty?
    assert_template "users/see_matches"
    assert_equal cr_user.picture, assigns["me_pic"]
    assert assigns["gender"].nil?
    assert assigns["status"].nil?
    assert_equal Network.find(:all), assigns["nets"]
    assert assigns["none"]
    assert_equal [], assigns["matches"]    
  end
  def test_see_matches_for_other_user
    Network.delete_all
    User.delete_all

    cr_user = get_richard
    cr_user2 = get_gram
    get :see_matches, get_params.merge!(:chosen_user_id=>cr_user2.id)
    assert_response :success

    # ok what happened?
    assert flash.empty?
    assert_template "users/see_matches"
    assert_equal cr_user2.picture, assigns["me_pic"]
    assert assigns["gender"].nil?
    assert assigns["status"].nil?
    assert_equal [Network.find_by_network("Beaux Arts")], assigns["nets"]
    assert assigns["none"]
    assert_equal [], assigns["matches"]    
  end
  def test_see_matches_with_matches
    Network.delete_all
    User.delete_all

    cr_user = get_richard
    cr_user2 = get_gram
    cr_user3 = get_mom

    coup1 = Couple.find_or_create(cr_user.picture.id,cr_user2.picture.id)
    coup1.refresh(0, 10)    
    coup2 = Couple.find_or_create(cr_user.picture.id,cr_user3.picture.id)
    coup2.refresh(0, 5)

    get :see_matches, get_params
    assert_response :success

    # ok what happened?
    assert flash.empty?
    assert_template "users/see_matches"
    assert_equal cr_user.picture, assigns["me_pic"]
    assert assigns["gender"].nil?
    assert assigns["status"].nil?
    assert_equal cr_user.networks, assigns["nets"]
    assert !assigns["none"]
    assert_equal [coup1,coup2], assigns["matches"]    
  end

  def test_see_matches_with_matches_and_gender_filter
    Network.delete_all
    User.delete_all

    cr_user = get_richard
    cr_user2 = get_gram
    cr_user3 = get_mom
    cr_user3.update_attribute(:gender,true)
    
    coup1 = Couple.find_or_create(cr_user.picture.id,cr_user2.picture.id)
    coup1.refresh(0, 10)    
    coup2 = Couple.find_or_create(cr_user.picture.id,cr_user3.picture.id)
    coup2.refresh(0, 5)

    get :see_matches, get_params.merge!("gender"=>"girls")
    assert_response :success

    # ok what happened?
    assert flash.empty?
    assert_template "users/see_matches"
    assert_equal cr_user.picture, assigns["me_pic"]
    assert_equal "girls", assigns["gender"]
    assert assigns["status"].nil?
    assert_equal cr_user.networks, assigns["nets"]
    assert !assigns["none"]
    assert_equal [coup1], assigns["matches"]    
  end

  def test_see_matches_with_matches_with_network_filter
    Network.delete_all
    User.delete_all

    cr_user = get_richard
    cr_user2 = get_gram
    cr_user3 = get_mom
 
    coup1 = Couple.find_or_create(cr_user.picture.id,cr_user2.picture.id)
    coup1.refresh(0, 10)    
    coup2 = Couple.find_or_create(cr_user.picture.id,cr_user3.picture.id)
    coup2.refresh(0, 5)

    net = Network.find_by_network("Beaux Arts") 
    get :see_matches, get_params.merge!("network"=>net.id)
    assert_response :success

    # ok what happened?
    assert flash.empty?
    assert_template "users/see_matches"
    assert_equal cr_user.picture, assigns["me_pic"]
    assert assigns["gender"].nil?
    assert assigns["status"].nil?
    assert_equal cr_user.networks, assigns["nets"]
    assert !assigns["none"]
    assert_equal [coup1], assigns["matches"]    
  end

  def test_see_matches_with_matches_with_gender_and_network_filters
    Network.delete_all
    User.delete_all

    cr_user = get_richard
    cr_user2 = get_gram
    cr_user3 = get_mom
    cr_user3.update_attribute(:gender,true)

    coup1 = Couple.find_or_create(cr_user.picture.id,cr_user2.picture.id)
    coup1.refresh(0, 10)    
    coup2 = Couple.find_or_create(cr_user.picture.id,cr_user3.picture.id)
    coup2.refresh(0, 5)

    net = Network.find_by_network("Beaux Arts") 
    get :see_matches, get_params.merge!("network_id"=>net.id, "gender"=>"girls")
    assert_response :success

    # ok what happened?
    assert flash.empty?
    assert_template "users/see_matches"
    assert_equal cr_user.picture, assigns["me_pic"]
    assert_equal "girls", assigns["gender"]
    assert assigns["status"].nil?
    assert_equal cr_user.networks, assigns["nets"]
    assert !assigns["none"]
    assert_equal [coup1], assigns["matches"]    
  end

  # STATUS options:
  #      when "all": ""
   #     when "love": "where both you like each other"
    #    when "i_like": "where you like them"
     #   when "they_like": "where they like you"
      #  when "i_secretly_like": "where you secretly like them"
       # when "unknown": "where we do not know"
  # love
  def test_see_matches_with_matches_with_status_to_love
    Network.delete_all
    User.delete_all

    cr_user = get_richard
    cr_user2 = get_gram
    cr_user3 = get_mom

    coup1 = Couple.find_or_create(cr_user.picture.id,cr_user2.picture.id)
    coup1.refresh(0, 10)    
    coup1.update_attributes(:picture1_likes_picture2 =>true, :picture2_likes_picture1=>true)
    coup2 = Couple.find_or_create(cr_user.picture.id,cr_user3.picture.id)
    coup2.refresh(0, 5)

    net = Network.find_by_network("Beaux Arts") 
    get :see_matches, get_params.merge!("status"=>"love")
    assert_response :success

    # ok what happened?
    assert flash.empty?
    assert_template "users/see_matches"
    assert_equal cr_user.picture, assigns["me_pic"]
    assert assigns["gender"].nil?
    assert_equal "love", assigns["status"]
    assert_equal cr_user.networks, assigns["nets"]
    assert !assigns["none"]
    assert_equal [coup1], assigns["matches"]    
  end
  # i like
  def test_see_matches_with_matches_with_status_to_i_like
    Network.delete_all
    User.delete_all

    cr_user = get_richard
    cr_user2 = get_gram
    cr_user3 = get_mom


    coup1 = Couple.find_or_create(cr_user.picture.id,cr_user2.picture.id)
    coup1.refresh(0, 10)    
    coup1.update_attributes(:picture1_likes_picture2 =>true, :picture2_likes_picture1=>false)
    coup2 = Couple.find_or_create(cr_user.picture.id,cr_user3.picture.id)
    coup2.refresh(0, 5)

    net = Network.find_by_network("Beaux Arts") 
    get :see_matches, get_params.merge!("status"=>"i_like")
    assert_response :success

    # ok what happened?
    assert flash.empty?
    assert_template "users/see_matches"
    assert_equal cr_user.picture, assigns["me_pic"]
    assert assigns["gender"].nil?
    assert_equal "i_like", assigns["status"]
    assert_equal cr_user.networks, assigns["nets"]
    assert !assigns["none"]
    assert_equal [coup1], assigns["matches"]    
  end
  # they like
  def test_see_matches_with_matches_with_status_to_they_like
    Network.delete_all
    User.delete_all

    cr_user = get_richard
    cr_user2 = get_gram
    cr_user3 = get_mom


    coup1 = Couple.find_or_create(cr_user.picture.id,cr_user2.picture.id)
    coup1.refresh(0, 10)    
    coup2 = Couple.find_or_create(cr_user.picture.id,cr_user3.picture.id)
    coup2.refresh(0, 5)

    coup1.update_attributes(:picture1_likes_picture2 =>false, :picture2_likes_picture1=>true)

    net = Network.find_by_network("Beaux Arts") 
    get :see_matches, get_params.merge!("status"=>"they_like")
    assert_response :success

    # ok what happened?
    assert flash.empty?
    assert_template "users/see_matches"
    assert_equal cr_user.picture, assigns["me_pic"]
    assert assigns["gender"].nil?
    assert_equal "they_like", assigns["status"]
    assert_equal cr_user.networks, assigns["nets"]
    assert !assigns["none"]
    assert_equal [coup1], assigns["matches"]    
  end
  # i secretly like
  def test_see_matches_with_matches_with_status_to_i_secretly_like
    Network.delete_all
    User.delete_all

    cr_user = get_richard
    cr_user2 = get_gram
    cr_user3 = get_mom

    coup1 = Couple.find_or_create(cr_user.picture.id,cr_user2.picture.id)
    coup1.refresh(0, 10)    
    coup2 = Couple.find_or_create(cr_user.picture.id,cr_user3.picture.id)
    coup2.refresh(0, 5)
    coup1.update_attributes(:picture1_secretly_likes_picture2 =>true, :picture2_likes_picture1=>false)

    net = Network.find_by_network("Beaux Arts") 
    get :see_matches, get_params.merge!("status"=>"i_secretly_like")
    assert_response :success

    # ok what happened?
    assert flash.empty?
    assert_template "users/see_matches"
    assert_equal cr_user.picture, assigns["me_pic"]
    assert assigns["gender"].nil?
    assert_equal "i_secretly_like", assigns["status"]
    assert_equal cr_user.networks, assigns["nets"]
    assert !assigns["none"]
    assert_equal [coup1], assigns["matches"]    
  end
  ############# END OF TESTING SEE MATCHES ###############
  # Like rate, we have the a callback called filter_matches
  # to handle posts.  Really not much important is here.
  # I cannot right now even test this stuff really.  All
  # is just passing params around and outputing flash notices.
  # TODO: Figure out how to test for redirects and all.
  ############# BEG OF TESTING FILTER MATCHES ###############
  def test_filter_matches_no_params
    Network.delete_all
    User.delete_all

    post :filter_matches, get_params
    assert_response :success
    
    assert !flash.empty?
    assert_template nil
  end
  ############# END OF TESTING FILTER MATCHES ############### 
  # To handle changes in status we have change matches
  ############# BEG OF TESTING CHANGE MATCHES ###############
  def test_change_matches_no_params
    Network.delete_all
    User.delete_all

    post :filter_matches, get_params
    assert_response :success
    
    assert !flash.empty?
    assert_template nil
  end
  def test_change_matches_with_some_inputs
    Network.delete_all
    User.delete_all

    cr_user = get_richard
    cr_user2 = get_gram
    cr_user3 = get_mom

    coup1 = Couple.find_or_create(cr_user.picture.id,cr_user2.picture.id)
    coup1.refresh(0, 10)    
    coup2 = Couple.find_or_create(cr_user.picture.id,cr_user3.picture.id)
    coup2.refresh(0, 5)
    assert !coup1.picture1_likes_picture2
    assert !coup2.picture2_secretly_likes_picture1

    input_name1 = coup1.id.to_s + "_likes"
    input_name2 = coup2.id.to_s + "_secret"
    post :change_matches, get_params.merge!({input_name1=>"1",input_name2=>"1", coup1.id.to_s=>"1", coup2.id.to_s=>"1"})
    assert_response :success

    coup1 = Couple.find(coup1.id)    
    coup2 = Couple.find(coup2.id)
    
    assert coup1.picture1_likes_picture2
    assert coup2.picture1_secretly_likes_picture2

    assert flash.empty?
    assert_template nil
  end
  ############# END OF TESTING CHANGE MATCHES ############### 
  # no go
  def test_see_friends
  #  get :see_friends, get_params
   # assert_response :success
  end
  def test_see_pictures
#    get :see_pictures, get_params
 #   assert_response :success
  end
  ###########################
  # Turns out that see_pictures is trouble, but we can do
  # change picture.  This approach suits me, ok.  We get
  # pretty good coverage here.
  ############# BEG OF TESTING CHANGE PICTURE ############### 

  def test_change_picture_when_pre_existing
    Picture.delete_all
    cr_user = get_richard
    pic = Picture.create(:fb_id=>1)
    cr_user.update_attribute(:picture_id, nil)
  
    post :change_picture, get_params.merge!("choice"=>1)
    assert_response :success

    cr_user = User.find(cr_user.id)
    assert_equal pic, cr_user.picture
    assert_template nil
    assert !flash.empty?
  end
  def test_change_picture_when_profile_picture
    Picture.delete_all
    cr_user = get_richard
    assert cr_user.picture.profile_pic?

    post :change_picture, get_params.merge!("choice"=>1)
    assert_response :success

    assert !Picture.exists?(:fb_id=>cr_user.id)
    cr_user = User.find(cr_user.id)
    assert_equal Picture.find_by_fb_id(1), cr_user.picture
    assert_template nil
    assert !flash.empty?
  end
  def test_change_picture_when_new_unknown_picture
    Picture.delete_all
    cr_user = get_richard
    cr_user.update_attribute(:picture_id,nil)
    assert !Picture.exists?(:fb_id=>0)
  
    post :change_picture, get_params.merge!("choice"=>0)
    assert_response :success

    cr_user = User.find(cr_user.id)
    assert_equal Picture.find_by_fb_id(0), cr_user.picture
    assert_template nil
    assert !flash.empty?
  end
  ############# END OF TESTING CHANGE PICTURE ############### 
  # Easy so I'll lump the two together
  ############## Beg OF SEE PRIVACY/ CHANGE PRIVACY ######
  def test_see_privacy
    cr_user = get_richard

    post :see_privacy, get_params
    assert_response :success

    assert_equal cr_user, assigns["user"]
    assert_template "users/see_privacy"
    assert flash.empty?
  end
  # Callback to change user settings
  def test_see_privacy
    cr_user = get_richard

    assert_equal "Richard", cr_user.first_name
    assert_equal "Jordan", cr_user.last_name
    assert cr_user.gender
    assert cr_user.with_men
    assert cr_user.with_women

    new_identity = {"user"=> {"first_name"=>"bob","last_name"=>"spider man",
		   "with_men"=>"false", "with_women"=>"false", "gender"=>false} }
    post :change_privacy, get_params.merge!(new_identity)
    assert_response :success

    cr_user= User.find(cr_user.id)
    assert_equal "bob", cr_user.first_name
    assert_equal "spider man", cr_user.last_name
    assert !cr_user.gender
    assert !cr_user.with_men
    assert !cr_user.with_women
    
    assert_template nil
    assert !flash.empty?
  end
  ############## END OF SEE/CHANGE PRIVACY ####
  
  # more API call actions
  def test_see_networks
#    get :see_networks, get_params
 #   assert_response :success
  end
  def test_change_networks
 #   get :see_networks, get_params
  #  assert_response :success
  end

  
end
