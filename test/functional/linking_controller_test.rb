require File.dirname(__FILE__) + '/../test_helper'

class LinkingControllerTest < ActionController::TestCase
  def test_couple
    User.delete_all
    cr_user = get_richard
    cr_user2 = get_gram
    coup = Couple.find_or_create(cr_user.picture.id,cr_user2.picture.id)

    get :couple, get_params.merge!("couplelink"=>coup.id)
    assert_response :success

    assert flash.empty?
    assert_template "linking/couple"
    assert_equal coup, assigns["couple"]  
  end
  def test_picture
    User.delete_all
    cr_user = get_richard

    get :picture, get_params.merge!("picturelink"=>cr_user.picture.id)
    assert_response :success

    assert flash.empty?
    assert_template "linking/picture"
    assert_equal cr_user.picture, assigns["picture"]  
  end
  def test_user_ratings
    User.delete_all
    cr_user = get_richard

    get :user_ratings, get_params.merge!("user_id"=>cr_user.id)
    assert_response :success

    assert flash.empty?
    assert_template "linking/user_ratings"
    assert_equal cr_user, assigns["user"]  
  end
  def test_couple_ratings
    User.delete_all
    cr_user = get_richard
    cr_user2 = get_gram
    coup = Couple.find_or_create(cr_user.picture.id,cr_user2.picture.id)

    get :couple_ratings, get_params.merge!("couple_id"=>coup.id)
    assert_response :success

    assert flash.empty?
    assert_template "linking/couple_ratings"
    assert_equal coup, assigns["couple"]  
  end
  def test_couple_network
    User.delete_all
    net = Network.create
    get :couple_network, get_params.merge!("network_id"=>net.id)
    assert_response :success

    assert flash.empty?
    assert_template "linking/couple_network"
    assert_equal net, assigns["net"]  
  end
  def test_user_network
    User.delete_all
    net = Network.create
    get :user_network, get_params.merge!("network_id"=>net.id)
    assert_response :success

    assert flash.empty?
    assert_template "linking/user_network"
    assert_equal net, assigns["net"]  
  end

  def test_see_all_with_nil
    User.delete_all
    cr_user = get_richard

    get :see_all, get_params
    assert_response :success

    assert !flash.empty?
    assert_template nil
    assert assigns["see_all"].nil?
  end
  def test_see_all_with_one_couples
    User.delete_all
    cr_user = get_richard
    cr_user2 = get_gram
    coup = Couple.find_or_create(cr_user.picture.id,cr_user2.picture.id)

    get :see_all, get_params.merge!("order"=>"most_rated")
    assert_response :success

    assert flash.empty?
    assert_template "linking/see_all"
    assert_equal [coup], assigns["see_all"]
  end
  def test_see_all_with_two_couples
    User.delete_all
    cr_user = get_richard
    cr_user2 = get_gram
    cr_user3 = get_mom
    coup1 = Couple.find_or_create(cr_user.picture.id,cr_user2.picture.id)
    coup2 = Couple.find_or_create(cr_user.picture.id,cr_user3.picture.id)
    get :see_all, get_params.merge!("order"=>"recent")
    assert_response :success

    assert flash.empty?
    assert_template "linking/see_all"
    assert_equal [coup1,coup2], assigns["see_all"]
  end
  
  def test_set_secret_new_couple
    User.delete_all
    Couple.delete_all
    cr_user = get_richard
    cr_user2 = get_gram

    assert !Couple.exists?(:picture_id1=>cr_user.id, :picture_id2=>cr_user2.id) and
           !Couple.exists?(:picture_id2=>cr_user.id, :picture_id1=>cr_user2.id)

    get :set_secret, get_params.merge!("who"=>cr_user2.id)
    assert_response :success

    assert Couple.exists?(:picture_id1=>cr_user.id, :picture_id2=>cr_user2.id) or
           Couple.exists?(:picture_id2=>cr_user.id, :picture_id1=>cr_user2.id)

    coup = cr_user.picture.couples.first
    assert coup.i_secretly_like?(cr_user.picture.id)
    assert !flash.empty?
    assert_template nil
  end
  def test_set_secret_and_both_like
    User.delete_all
    Couple.delete_all
    cr_user = get_richard
    cr_user2 = get_gram

    coup = Couple.find_or_create(cr_user.picture.id,cr_user2.picture.id)
    coup.update_attribute(:picture2_secretly_likes_picture1,true)
    assert coup.i_secretly_like?(cr_user2.picture.id)

    get :set_secret, get_params.merge!("who"=>cr_user2.id)
    assert_response :success

    coup = cr_user.picture.couples.first
    
    assert coup.i_secretly_like?(cr_user.picture.id)
    assert coup.both_like?
    assert flash.empty?
    assert_template nil
  end

  def test_rate_chosen_couple_without_params
    User.delete_all
    Couple.delete_all
    cr_user = get_richard
    cr_user2 = get_gram

    get :rate_chosen_couple, get_params
    assert_response :success

    assert flash[:notice]
    assert_template nil
  end
  def test_rate_chosen_couple_with_params
    User.delete_all
    Couple.delete_all
    cr_user = get_richard

    get :rate_chosen_couple, get_params.merge!({:chosen_picture_id1=>"43432", :chosen_picture_id2=>"443234" })
    assert_response :success

    assert flash[:notice]
    assert_template nil
  end

  def test_see_matches_of_chosen_user_without_params
    User.delete_all
    Couple.delete_all
    cr_user = get_richard

    get :see_matches_of_chosen_user, get_params
    assert_response :success

    assert flash[:notice]
    assert_template nil
  end
  def test_see_matches_of_chosen_user_with_params
    User.delete_all
    Couple.delete_all
    cr_user = get_richard

    get :see_matches_of_chosen_user, get_params.merge!(:chosen_user_id=>cr_user.id)
    assert_response :success

    assert !flash[:notice].nil?
    assert_template nil
  end
end
