# Habtm with users and couples.
# Allows us to handle filtering
# and keep some level of privacy
# as well as make smaller pools
# of couples to avoid the so-called
# n-squared problem where we would
# have too large of pools of couples
# and each would get too few votes.
class Network < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_and_belongs_to_many :couples
 
  # sort by network name in alphabetical order.
  def <=>(other)
    (network<=>other.network)
  end
  

  def Network.find_or_create(fb_id, name)
    if(Network.exists?(:fb_id=>fb_id))
      network = Network.find_by_fb_id(fb_id)
    else
      network = Network.create(:fb_id=>fb_id, :network=>name)
    end
    network
  end

  def couples_with_picture(pic_id)
	couples.find(:all, :conditions=> ["picture_id1 = ? OR picture_id2 = ?", pic_id, pic_id])
  end
end
