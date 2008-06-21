require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  def test_find_or_create
    # test when the user exists
    fb_user = FacebookerUser.new(1,"male","Bob", "the spider man",[FacebookerAffiliation.new(1,"test1"),
					FacebookerAffiliation.new(2,"test2"),
					FacebookerAffiliation.new(3,"test3")])
    user = User.find(users(:one).id)
    assert_equal user, User.find_or_create(fb_user.uid, fb_user.sex,
				fb_user.first_name, fb_user.last_name, fb_user.affiliations)

    # create new user
    fb_user = FacebookerUser.new(0,"male","Rob", "jordan",[FacebookerAffiliation.new(1,"test1"),
					FacebookerAffiliation.new(2,"test2"),
					FacebookerAffiliation.new(3,"test3")])
    assert !User.exists?(:fb_id=>fb_user.uid)
    user = User.find_or_create(fb_user.uid,fb_user.sex,fb_user.first_name, fb_user.last_name,fb_user.affiliations)
    assert User.exists?(:fb_id=>fb_user.uid)
    assert_not_nil Picture.find_by_fb_id(fb_user.uid)
    nets = Network.find([networks(:one).id,networks(:two).id,networks(:three).id])
    assert_equal nets.sort { |x,y| x.network<=>y.network },
		user.networks.sort { |x,y| x.network<=>y.network }
  end

  def test_update_picture
    # no current picture and picture does not exist
    user = User.create(:fb_id=>1)
    assert_equal [], user.pictures
    user.update_picture(1)
    assert_equal Picture.find_by_fb_id(1), user.picture

    # no current picture and picture exists
    User.delete_all
    Picture.delete_all     
    user = User.create(:fb_id=>1)
    pic = Picture.create(:fb_id=>1)
    user.update_picture(pic.fb_id)
    assert_equal [pic], user.pictures
    assert_equal pic, user.picture

    # current picture and exists but profile
    pic2 = Picture.create(:fb_id=>55)
    user.update_picture(pic2.fb_id)
    user = User.find(user.id)
    pic = Picture.find(pic.id)
    assert_equal [pic], user.pictures
    assert_equal pic, user.picture
    assert !Picture.exists?(:fb_id=>1)
    assert_equal 55, pic.fb_id

    # current picture and exists and non profile
    pic3 = Picture.create(:fb_id=>13)
    user.update_picture(pic3.fb_id)
    assert_equal [pic,pic3], user.pictures
    assert_equal pic3, user.picture
    assert_equal 13, user.picture.fb_id
  end
  
  def test_networks_with
    # none
    u1 = User.create
    u2 = User.create
    assert_equal [], u1.networks_with(u2)

    # one
    n1 = Network.create
    u1.networks << n1
    u2.networks << n1
    assert_equal [n1], u1.networks_with(u2)

    # two
    n2 = Network.create
    u1.networks << n2
    u2.networks << n2
    assert_equal [n1,n2], u1.networks_with(u2)
  end

  # Tests the method for finding couples from the database given an 
  # orientation.  Specifically, makes sure that the individuals returned 
  # have genders and preferences appropriate for the given orientation, 
  # and that when some couple can be returned a couple is returned.
  def test_findy
        # ensure nil is returned when the database is empty
        User.delete_all
	# 0 users lesbian
	assert_nil User.findy("lesbian")
	#0 gay
	assert_nil User.findy("gay")
        #0 straight
        assert_nil User.findy("straight")
        #0 ... people
        assert_nil User.findy("bi")

        # Make sure that users who don't want to be paired with anyone 
        # are never in a couple
        User.create({:gender=>false, :with_women=>false, :with_men=>false})
        User.create({:gender=>false, :with_women=>false, :with_men=>false})
        User.create({:gender=>true, :with_women=>false, :with_men=>false})
        User.create({:gender=>true, :with_women=>false, :with_men=>false})
        assert_nil User.findy("bi")
        assert_nil User.findy("gay")
        assert_nil User.findy("lesbian")
        assert_nil User.findy("straight")
        User.create({:gender=>true, :with_women=>true, :with_men=>false})
        User.create({:gender=>true, :with_women=>false, :with_men=>true})
        assert_nil User.findy("bi")
        assert_nil User.findy("gay")
        assert_nil User.findy("lesbian")
        assert_nil User.findy("straight")
        User.create({:gender=>true, :with_women=>true, :with_men=>true})
        User.create({:gender=>false, :with_women=>true, :with_men=>true})
        User.create({:gender=>false, :with_women=>true, :with_men=>false})
        User.create({:gender=>false, :with_women=>false, :with_men=>true})

        
        200.times do |n|
          findy_helper(User.findy("bi"))
          findy_helper(User.findy("lesbian"))
          findy_helper(User.findy("straight"))
          findy_helper(User.findy("gay"))
        end
  end

  # check to make sure the individuals in the couples have the proper 
  #  orientation to be paired with each other (e.g., if one user is a 
  #  man, the other user's with_men preference must be true)
  # parameter couple: two users in an array
  def findy_helper(couple)
    if(assert couple != nil)
      if(couple[0].gender)
        assert couple[1].with_men
      else
        assert couple[1].with_women
      end
      if(couple[1].gender)
        assert couple[0].with_men
      else
        assert couple[0].with_women
      end
    end
  end

  # test to make sure findyPeopleFromOrientation actually returns a 
  # person with the right gender and preferences
  def test_findyPeopleFromOrientation
    make_peeples()
    users = User.find(:all)
    peeple = User.findyPeopleFromOrientation(users, "gay")
    peeple.each {|n| assert n.gender and n.with_men }
    peeple = User.findyPeopleFromOrientation(users, "lesbian")
    peeple.each {|n| assert !n.gender && n.with_women }
    peeple = User.findyPeopleFromOrientation(users, "straight")
    peeple.each {|n| assert ((n.gender && n.with_women) || ((not n.gender) && n.with_men)) }
    peeple = User.findyPeopleFromOrientation(users, "bi")
    peeple.each {|n| assert n.with_women || n.with_men }
  end

  # test User.findyMatchByOrientation to make sure it always returns an 
  # appropriate couple, and to ensure that it returns nil when only one 
  # suitable person can be found.
  def test_findyMatchByOrientation
    # make sure nil is returned when db is empty
    assert_nil User.findyMatchByOrientation(nil, nil, "test")
    assert_nil User.findyMatchByOrientation([], nil, "test")

    # make sure that nil is returned when there are only people in the 
    # database whose preferences do not allow them to be paired with 
    # anyone
    User.create({:gender=>true, :with_women=>false, :with_men=>false})
    User.create({:gender=>false, :with_women=>false, :with_men=>false})
    User.create({:gender=>true, :with_women=>false, :with_men=>false})
    User.create({:gender=>false, :with_women=>false, :with_men=>false})
    users = User.find(:all)
    no_match_man = User.find(:all, :conditions=>['gender=?', true])
    no_match_girl = User.find(:all, :conditions=>['gender=?', false])
    assert_nil User.findyMatchByOrientation(users, no_match_man, "gay")
    assert_nil User.findyMatchByOrientation(users, no_match_man, "straight")
    assert_nil User.findyMatchByOrientation(users, no_match_girl, "straight")
    assert_nil User.findyMatchByOrientation(users, no_match_girl, "lesbian")
    assert_nil User.findyMatchByOrientation(users, no_match_man, "bi")
    assert_nil User.findyMatchByOrientation(users, no_match_girl, "bi")

    # make sure nil is returned when the preferences of the users in the 
    # db do not allow them to be paired with each other.
    User.create({:gender=>true, :with_women=>true, :with_men=>true})
    users = User.find(:all, :conditions=>['gender=? AND with_men=? AND with_women=?', true, true, true])
    man = users[0]
    assert_nil User.findyMatchByOrientation(users, man, "gay")
    assert_nil User.findyMatchByOrientation(users, man, "straight")
    assert_nil User.findyMatchByOrientation(users, man, "bi")
    User.create({:gender=>false, :with_women=>true, :with_men=>false})
    woman = User.find(:all, :conditions=>['gender=? AND with_women=?', false, true])[0]
    assert_nil User.findyMatchByOrientation(users, woman, "lesbian")
    assert_nil User.findyMatchByOrientation(users, man, "bi")
    assert_nil User.findyMatchByOrientation(users, woman, "bi")
    assert_nil User.findyMatchByOrientation(users, man, "straight")
    assert_nil User.findyMatchByOrientation(users, woman, "straight")
    
    # make sure that appropriate couples are formed when user 
    # preferences and genders allow pairs to be formed.
    make_peeples()
    users = User.find(:all)
    20.times do |n|
      man = User.findyPeopleFromOrientation(users, "gay").rand
      couple = User.findyMatchByOrientation(users, man, "gay")
      assert couple[0].gender && couple[1].gender
      assert couple[0].with_men && couple[1].with_men
      assert couple[1].getId != couple[0].getId
    end
    20.times do |n|
      woman = User.findyPeopleFromOrientation(users, "lesbian").rand
      couple = User.findyMatchByOrientation(users, woman, "lesbian")
      assert couple[0].gender == false && couple[1].gender == false
      assert couple[0].with_women && couple[1].with_women
      assert couple[1].getId != couple[0].getId
    end
    20.times do |n|
      one = User.findyPeopleFromOrientation(users, "straight").rand
      couple = User.findyMatchByOrientation(users, one, "straight")
      one = couple[0]
      two = couple[1]
      assert (one.gender || two.gender) && (!one.gender || !two.gender)
      assert one.with_women if one.gender
      assert one.with_men if !one.gender
      assert two.with_women if two.gender
      assert two.with_men if !two.gender
    end
    20.times do |n|
      one = User.findyPeopleFromOrientation(users, "bi").rand
      couple = User.findyMatchByOrientation(users, one, "bi")
      one = couple[0]
      two = couple[1]
      assert one.with_men if two.gender
      assert one.with_women if !two.gender
      assert two.with_men if one.gender
      assert two.with_women if !one.gender
      assert one.getId != two.getId
    end
  end

  # makes test users for testing findy type methods
  def make_peeples
    User.create({:gender=>true, :with_women=>true, :with_men=>true})
    User.create({:gender=>false, :with_women=>true, :with_men=>true})
    User.create({:gender=>false, :with_women=>true, :with_men=>false})
    User.create({:gender=>false, :with_women=>false, :with_men=>true})  
    User.create({:gender=>true, :with_women=>true, :with_men=>false})
    User.create({:gender=>true, :with_women=>false, :with_men=>true})
    User.create({:gender=>false, :with_women=>false, :with_men=>false})
    User.create({:gender=>false, :with_women=>false, :with_men=>false})
    User.create({:gender=>true, :with_women=>false, :with_men=>false})
    User.create({:gender=>true, :with_women=>false, :with_men=>false})
  end

  def test_default_gender
    # male is gender==true

    # bi
    user = User.create({:gender=>true, :with_women=>true,:with_men=>true})
    assert_equal "bi", user.default_gender
    #gay    
    user = User.create({:gender=>true, :with_women=>false,:with_men=>true})
    assert_equal "gay", user.default_gender
    #lesbian
    user = User.create({:gender=>false, :with_women=>true,:with_men=>false})
    assert_equal "lesbian", user.default_gender
    # straight
    user = User.create({:gender=>true, :with_women=>true,:with_men=>false})
    assert_equal "straight", user.default_gender
    user = User.create({:gender=>false, :with_women=>false,:with_men=>true})
    assert_equal "straight", user.default_gender
  end

  # for an uninstall, we wipe out the user and all his associations
  def test_kill
    User.delete_all
    Couple.delete_all
    Picture.delete_all
    Network.delete_all
    Rating.delete_all

    fb_user = FacebookerUser.new(1,"male","Bob", "the spider man",[FacebookerAffiliation.new(1,"test1"),
					FacebookerAffiliation.new(2,"test2"),
					FacebookerAffiliation.new(3,"test3")])
    user = User.find_or_create(fb_user.uid, fb_user.sex,
				fb_user.first_name, fb_user.last_name, fb_user.affiliations)
    other = User.find_or_create(2, fb_user.sex, "Johnny", "B. Good", [])
    n1 = Network.create
    user.networks << n1
    other.networks << n1

    coup_rated = Couple.create
    user_rat = user.ratings.create(:rating=>10, :couple_id=>coup_rated.id)
    coup_rated.ratings.create(:rating=>5)
    coup_rated.update_attributes(:ratings_sum=>15,:ratings_count=>2)
 
    pic = user.pictures.create
    coup = Couple.find_or_create(user.picture.id, other.picture.id)
    coup.refresh_networks
    coup_rat = coup.ratings.create
    


    uid = user.id
    urid = user_rat.id
    active_pid = user.picture.id
    passive_pid = pic.id
    cid = coup.id
    crid = coup_rat.id   
    nids = user.networks.collect { |net| net.id }
   
    user.kill

    assert !Rating.exists?(urid)
    assert Rating.find_by_user_id(uid).nil?
    assert !Rating.exists?(crid)
    assert Rating.find_by_couple_id(cid).nil?
    assert !Picture.exists?(active_pid)
    assert !Picture.exists?(passive_pid)
    assert Picture.find_by_user_id(uid).nil?
    assert !Couple.exists?(cid)
    assert Couple.find_by_picture_id1(active_pid,passive_pid).nil?
    assert Couple.find_by_picture_id2(active_pid,passive_pid).nil?
    assert !User.exists?(uid)

    assert Network.exists?(n1.id) # keep the couple networks
    assert !n1.couples.exists?(cid)
    assert !n1.users.exists?(uid)
    nids.each { |nid| 
	assert Network.exists?(nid) # keep the user networks
     }
    
    assert Couple.exists?(coup_rated.id)
    assert_equal 1, Couple.find(coup_rated.id).ratings_count
    assert_equal 5, Couple.find(coup_rated.id).ratings_sum
  end

  def test_find_a_network_with_two_users
    Network.delete_all
    User.delete_all
    user = User.create(:with_men=>true,:with_women=>true,:gender=>true)
    assert [], user.networks
    # no networks even
    assert user.find_a_network_with_two_users.nil?

    # has network still noone
    net = Network.create
    user.networks << net
    assert user.find_a_network_with_two_users.nil?

    # true now
    user2 = User.create(:with_men=>true,:with_women=>true,:gender=>true)
    user2.networks << net
    assert_equal net, user.find_a_network_with_two_users

    # gender mismatch so no now
    user2.update_attribute(:with_men,false)
    assert user.find_a_network_with_two_users.nil?
  end

  def test_flip_question_mark_setting
    user = User.create
    assert !user.see_question_marks

    user.flip_question_mark_setting
    assert user.see_question_marks

    user.flip_question_mark_setting
    assert !user.see_question_marks
  end
end
