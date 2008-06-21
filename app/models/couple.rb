# Couple is a class which holds two pictures.
# These pictures may or may not have users.
# The couple also caches ratings count and
# ratings sums for easy access.  The couple
# finally also holds "liking" settings such
# as picture 1 like picture 2 and so one.
# Also, a couple has many networks which it
# is part of and is shown in.
class Couple < ActiveRecord::Base
  has_many :ratings
  has_and_belongs_to_many :networks

  # compares by average rating
  def <=>(other)
    (other.average_rating<=>average_rating)
  end

  # Returns the averate rating with 2 decimal places,
  # and on divide by zero, returns zero.
  def average_rating
    if(ratings_count == 0)
      0
    else
      (ratings_sum.quo(ratings_count).to_f() *100).round/100.0
    end
  end

  # belongs_to :picture # actually two pictures?, won't work
  # so do these two.  Their must be a way to get the has_two
  # relationship working.
  def picture1
    Picture.find(picture_id1)
  end

  # Returns the second picture
  def picture2
    Picture.find(picture_id2)
  end

  def picture1_likes?
	(picture1_secretly_likes_picture2 || picture1_likes_picture2)
  end

  def picture2_likes?
	(picture2_secretly_likes_picture1 || picture2_likes_picture1)
  end

  # Returns true if secretly or openly both like each other
  def both_like?
	(picture1_likes? and picture2_likes?)
  end

  # Secretly or openly, one and only one likes
  def one_like?
    (picture1_likes? and !picture2_likes?) or 
    (!picture1_likes? and picture2_likes?)
  end
 
  # Secretly or openly, one or both may like, 
  # but for sure i do
  def i_like?(me_id)
    (i_openly_like?(me_id) or i_secretly_like?(me_id))
  end

  # The given picture openly likes the other
  def i_openly_like?(me_id)
    (picture1_likes_picture2 and (picture_id1==me_id) ) or
    (picture2_likes_picture1 and (picture_id2==me_id) )
  end

  # The given picture secretly likes the other
  def i_secretly_like?(me_id)
    (picture1_secretly_likes_picture2 and (picture_id1==me_id) ) or
    (picture2_secretly_likes_picture1 and (picture_id2==me_id) )
  end

  def not_me(me_id)
    if(picture_id1 == me_id)
       picture2
    else
       picture1
    end
  end

  # Returns a couple with the given two picture ids.
  # Avoids duplicates of a couple making sure couple(u1,u2)
  # does not duplicate couple(u2,u1).
  def Couple.find_or_create(pic_id1, pic_id2)
    if(!Picture.exists?(pic_id1) || !Picture.exists?(pic_id2) )
	raise "You cannot create a couple out of nonexistant pictures"
    end
    if(exists?({:picture_id1=>[pic_id1,pic_id2],
                        :picture_id2=>[pic_id1,pic_id2]}))
        couple = find_by_picture_id1_and_picture_id2([pic_id1,pic_id2],
                                [pic_id1,pic_id2])
    else
        couple = create({:picture_id1=>pic_id1,:picture_id2=>pic_id2,
			:picture1_likes_picture2=>false, :picture2_likes_picture1=>false,
			:ratings_sum=>0, :ratings_count=>0, 
			:picture1_secretly_likes_picture2=>false, 
			:picture2_secretly_likes_picture1=>false})
    end
    couple.refresh_networks if(couple.picture1.user_id and couple.picture2.user_id)
    couple
  end

  # Adds only the networks that u1 & u2 
  # have in common.
  def refresh_networks
     networks.clear
     networks << picture1.user.networks_with(picture2.user)    
  end

  # Returns all couples in created at order with
  # most recently created first  
  def Couple.newest
    Couple.find(:all, :order => "created_at DESC")
  end

  # Returns all couples in updated at order with
  # most recently updated first
  def Couple.most_recent
    Couple.find(:all, :order => "updated_at DESC")    
  end

  # Returns the couple sorted by ratings count
  def Couple.most_rated
    Couple.find(:all, :order => "ratings_count DESC")
  end
  
  # Returns all couples from high average rating
  # to low average rating
  def Couple.highest_rated
    Couple.find(:all).sort
  end

  # Sets the secret value for the correct picture which
  # secretly likes the other picture.
  def set_secret_for(actor, value = true)
    if(actor.picture == picture1)
            update_attribute(:picture1_secretly_likes_picture2,value)
    else
            update_attribute(:picture2_secretly_likes_picture1,value)
    end
  end

  # Sets the like value for the correct picture which
  # likes the other picture.
  def set_like_for(actor, value = true)
    if(actor.picture == picture1)
            update_attribute(:picture1_likes_picture2,value)
    else
            update_attribute(:picture2_likes_picture1,value)
    end
  end

  # Helper method for refresh_all that
  # works on individual couples
  def refresh(user_id=nil,r_value=0)
    if(!user_id.nil?)
      ratings.create(:user_id=>user_id,:rating=>r_value)
    end
    sum = ratings.inject(0) {|sum,n| sum+n.rating}
    update_attributes({:ratings_count=>ratings.length, :ratings_sum=> sum})
    self
  end

  # Class method that refreshes the ratings_count and 
  # ratings_sum that we cache in the couple
  # from its ratings.
  def Couple.refresh_all
    find(:all).each { |coup| coup.refresh }
  end

  # Return the number 1 plus "vote" instead 
  # of "votes" if the couple has one vote.
  def votes_in_words
    if(ratings_count ==1)
	ratings_count.to_s + " vote"
    else
	ratings_count.to_s + " votes"
    end
  end

  # Prints out a "-" in
  # place of a "0" for zero rated couples
  def average_in_words
    if(average_rating ==0)
	"-"
    else
       average_rating.to_s
    end
  end

  # Tells us if we have a couple created
  # out of two users or if one of
  # the pictures is just a friend of a
  # user and does not have our app.
  def both_pictures_are_users?
    ( !picture1.user_id.nil? and
        !picture2.user_id.nil?)
  end
end
