require File.dirname(__FILE__) + '/../test_helper'

class FacebookerAffiliation
   attr_accessor :nid
   attr_accessor :name
   def initialize(nid, name)
	@nid = nid
	@name = name
   end
end

class NetworkTest < ActiveSupport::TestCase
  def test_find_or_create
    affil = FacebookerAffiliation.new(1,"test1")
    # test when the network exists
    net = Network.find(networks(:one).id)
    assert_equal net, Network.find_or_create(affil.nid,affil.name)

    # create new couple
    affil = FacebookerAffiliation.new(0,"test0")
    assert  !Network.exists?(:fb_id=>affil.nid)
    Network.find_or_create(affil.nid,affil.name)
    assert  Network.exists?(:fb_id=>affil.nid)
  end

  def test_couples_with_picture
    net = Network.create
    pic = Picture.create
    c1 = Couple.create(:picture_id1=>pic.id)
    c2 = Couple.create(:picture_id2=>pic.id)
    c3 = Couple.create
    c4 = Couple.create(:picture_id2=>pic.id)
    c5 = Couple.create(:picture_id2=>pic.id)
 
    net.couples << [c1,c2,c3,c5]

    assert_equal [c1,c2,c5], net.couples_with_picture(pic.id)
  end
end
