require File.dirname(__FILE__) + '/../test_helper'

class PictureTest < ActiveSupport::TestCase
  def test_couples
    pic = Picture.create
    #all
    one = Couple.create(:picture_id1=>pic.id)
    two = Couple.create(:picture_id1=>pic.id)
    three = Couple.create(:picture_id2=>pic.id)
    assert_equal [one,two,three], pic.couples
 
    #boys/girls
    Couple.delete_all
    pboy=Picture.create
    boy = User.create(:gender=>true,:picture_id=>pboy.id)
    boy.pictures << pboy

    pgirl=Picture.create
    girl = User.create(:gender=>false,:picture_id=>pgirl.id)
    girl.pictures << pgirl

    pgirl2=Picture.create
    girl2 = User.create(:gender=>false,:picture_id=>pgirl2.id)
    girl2.pictures << pgirl2

    one = Couple.create(:picture_id1=>pic.id, :picture_id2=>pboy.id)
    two = Couple.create(:picture_id1=>pic.id, :picture_id2=>pgirl.id)
    three = Couple.create(:picture_id2=>pic.id, :picture_id1=>pgirl2.id)
    assert_equal [one], pic.couples("boys")
    assert_equal [two,three], pic.couples("girls")
    assert_equal [], pic.couples("boyzzz")
  end

  def test_find_or_create
    Picture.delete_all
    User.delete_all

    # not exist
    assert !Picture.exists?(:fb_id=>0)
    pic = Picture.find_or_create(0)
    assert Picture.exists?(:fb_id=>0)

    # exists
    assert_equal pic, Picture.find_or_create(0)
  end
 
  def test_profile_pic?
    # true
    pic = Picture.create({:fb_id=>10})
    user = User.create(:picture_id=>pic.id, :fb_id=>10)
    user.pictures << pic
    assert user.picture.profile_pic?

    # false
    user.picture.update_attribute(:fb_id,200)
    assert !user.picture.profile_pic?
  end

  def test_user_or_fake_user
    # user
    pic = Picture.create(:fb_id=>13)
    user = User.create
    user.update_picture(pic.fb_id)
    pic = Picture.find(pic.id)
    assert_equal user, pic.user_or_fake_user

    # no user
    pic = Picture.create(:fb_id=>12)
    assert !User.exists?(:picture_id=>pic.id)
    user = pic.user_or_fake_user
    assert !User.exists?(:picture_id=>pic.id)
    assert_equal pic.fb_id, user.fb_id
    assert_equal pic, user.picture
    assert_equal [pic], user.pictures
    assert_equal pic.id, user.picture_id
    assert_equal [], user.ratings
    assert_equal [], user.networks
  end
end

