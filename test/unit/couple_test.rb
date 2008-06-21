require File.dirname(__FILE__) + '/../test_helper'

class CoupleTest < ActiveSupport::TestCase
  def test_picture1
    one = Picture.create
    coup = Couple.create(:picture_id1=>one.id)
    assert_equal one, coup.picture1
  end

  def test_picture2
    two = Picture.create
    coup = Couple.create(:picture_id2=>two.id)
    assert_equal two, coup.picture2
  end

  
  def test_picture1_likes
    #true open
    couple = Couple.create(:picture1_likes_picture2=>true)
    assert couple.picture1_likes?
    #false
    couple = Couple.create(:picture1_likes_picture2=>false)
    assert !couple.picture1_likes?

    #true secret
    couple = Couple.create(:picture1_secretly_likes_picture2=>true)
    assert couple.picture1_likes?
    #false
    couple = Couple.create(:picture1_secretly_likes_picture2=>false)
    assert !couple.picture1_likes?
  end
  def test_picture2_likes
    #true open
    couple = Couple.create(:picture2_likes_picture1=>true)
    assert couple.picture2_likes?
    #false
    couple = Couple.create(:picture2_likes_picture1=>false)
    assert !couple.picture2_likes?

    #true secret
    couple = Couple.create(:picture2_secretly_likes_picture1=>true)
    assert couple.picture2_likes?
    #false
    couple = Couple.create(:picture2_secretly_likes_picture1=>false)
    assert !couple.picture2_likes?
  end

  def test_both_like?
    # true open
    couple = Couple.create({ :picture1_likes_picture2=>true, :picture2_likes_picture1=>true})
    assert couple.both_like?
    # true secret
    couple = Couple.create({ :picture1_secretly_likes_picture2=>true, :picture2_likes_picture1=>true})
    assert couple.both_like?

    #false
    couple = Couple.create({ :picture1_likes_picture2=>false, :picture2_likes_picture1=>true})
    assert !couple.both_like?
  end

  def test_one_like?
    # true open
    couple = Couple.create({ :picture1_likes_picture2=>true, :picture2_likes_picture1=>false})
    assert couple.one_like?
    # true secret
    couple = Couple.create({ :picture1_secretly_likes_picture2=>true, :picture2_likes_picture1=>false})
    assert couple.one_like?

    #false neg
    couple = Couple.create({ :picture1_likes_picture2=>false, :picture2_likes_picture1=>false})
    assert !couple.one_like?

    #false pos
    couple = Couple.create({ :picture1_likes_picture2=>true, :picture2_likes_picture1=>true})
    assert !couple.one_like?
  end

  def test_i_secretly_like?
    # true
    me = Picture.create
    not_me = Picture.create
    couple = Couple.create({ :picture_id1=>me.id, :picture_id2=>not_me.id, :picture1_secretly_likes_picture2=>true, 
				:picture2_secretly_likes_picture1=>false})
    assert couple.i_secretly_like?(me.id)

    #false
    me = Picture.create
    not_me = Picture.create
    couple = Couple.create({ :picture_id1=>me.id, :picture_id2=>not_me.id, :picture1_secretly_likes_picture2=>false, 
				:picture2_secretly_likes_picture1=>true})
    assert !couple.i_secretly_like?(me.id)
  end
  def test_i_openly_like?
    # true
    me = Picture.create
    not_me = Picture.create
    couple = Couple.create({ :picture_id1=>me.id, :picture_id2=>not_me.id, :picture1_likes_picture2=>true, :picture2_likes_picture1=>false})
    assert couple.i_like?(me.id)

    #false
    me = Picture.create
    not_me = Picture.create
    couple = Couple.create({ :picture_id1=>me.id, :picture_id2=>not_me.id, :picture1_likes_picture2=>false, :picture2_likes_picture1=>true})
    assert !couple.i_like?(me.id)
  end

  def test_not_me
    # left side
    me = Picture.create
    not_me = Picture.create
    couple = Couple.create({:picture_id1=>not_me.id,:picture_id2=>me.id})
    assert_equal not_me, couple.not_me(me.id)

    # right side
    me = Picture.create
    not_me = Picture.create
    couple = Couple.create({:picture_id1=>me.id,:picture_id2=>not_me.id})
    assert_equal not_me, couple.not_me(me.id)
  end

  def test_find_or_create
    Couple.delete_all
    Picture.delete_all
    # test when the couple exists
    p1 = Picture.create
    p2 = Picture.create
    coup = Couple.create(:picture_id1=>p1.id,
			 :picture_id2=>p2.id)
    assert_equal coup, Couple.find_or_create(p1.id,p2.id)
    assert_equal coup, Couple.find_or_create(p2.id,p1.id)

    # create new couple
    p1 = Picture.create
    p2 = Picture.create
    assert  !Couple.exists?({:picture_id1=>[p1.id,p2.id],
    			:picture_id2=>[p2.id,p1.id]})
    Couple.find_or_create(p2.id,p1.id) 
    assert Couple.exists?({:picture_id1=>[p1.id,p2.id],
    			:picture_id2=>[p2.id,p1.id]})

    # get error for nonexisting picture
    assert !Picture.exists?(0)
    assert_raises (RuntimeError) { Couple.find_or_create(p1.id, 0) }
  end

  def test_refresh_networks
    n1 = Network.create
    n2 = Network.create
    nboth = Network.create

    p1 = Picture.create
    u1 = User.create
    u1.pictures << p1
    u1.networks << [n1,nboth]

    p2 = Picture.create
    u2 = User.create
    u2.pictures << p2
    u2.networks << [n2,nboth]
    coup = Couple.create(:picture_id1=>p1.id,
			:picture_id2=>p2.id)
    coup.refresh_networks
    assert_equal [nboth], coup.networks
  end

  def test_newest     
    Couple.delete_all
    a = Couple.create
    a.update_attributes({:created_at =>"1"})
    b = Couple.create
    b.update_attributes({:created_at=>"22"})
    c = Couple.create
    c.update_attributes({:created_at=>"0"})

  #  assert_equal [b,a,c], Couple.newest
  end

  def test_most_recent
    Couple.delete_all
    a = Couple.create({:updated_at=>"3"})
    b = Couple.create({:updated_at=>"1"})
    c = Couple.create({:updated_at=>"10"})

 #   assert_equal [c,a,b], Couple.most_recent
  end

  def test_most_rated
    Couple.delete_all 
    a = Couple.create({:ratings_count=>1})
    b = Couple.create({:ratings_count=>3})
    c = Couple.create({:ratings_count=>2})

    assert_equal [b,c,a], Couple.most_rated
  end
  def test_highest_rated
    Couple.delete_all
    a = Couple.create({:ratings_count=>1,:ratings_sum=>8})
    b = Couple.create({:ratings_count=>3,:ratings_sum=>9})
    c = Couple.create({:ratings_count=>2,:ratings_sum=>20})

    assert_equal [c,a,b], Couple.highest_rated
  end

  def test_set_secret_for
    user_pic = Picture.create
    user = User.create(:picture_id=>user_pic.id)
    user.pictures << user_pic
    couple = Couple.create(:picture_id1=>user.picture.id)
    couple.set_secret_for(user)

    assert couple.picture1_secretly_likes_picture2
  end
  def test_set_like_for
    user_pic = Picture.create
    user = User.create(:picture_id=>user_pic.id)
    user.pictures << user_pic
    couple = Couple.create(:picture_id1=>user.picture.id)
    couple.set_like_for(user)

    assert couple.picture1_likes_picture2
  end
 
  def test_refresh
    coup = Couple.create(:ratings_count=>0,:ratings_sum=>0)
    coup.refresh
    assert_equal 0, coup.ratings_count
    assert_equal 0, coup.ratings_sum

    coup.refresh(1, 10)
    assert_equal 1, coup.ratings_count
    assert_equal 10, coup.ratings_sum

    coup = Couple.find(coup.id)
    rat = Rating.create(:couple_id=>coup.id, :rating=>5)
    coup.refresh
    assert_equal 2, coup.ratings_count
    assert_equal 15, coup.ratings_sum
    
    coup = Couple.find(coup.id)
    rat.destroy
    coup.refresh
    assert_equal 1, coup.ratings_count
    assert_equal 10, coup.ratings_sum
    
    coup = Couple.find(coup.id)
    Rating.find_by_user_id(1).destroy
    coup.refresh
    assert_equal 0, coup.ratings_count
    assert_equal 0, coup.ratings_sum 
    # return the couple
    assert coup, coup.refresh   
  end
end
