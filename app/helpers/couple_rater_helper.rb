# Gives us a random friend getting for
# organization and also the fake couple
# class to handle couples if we want to
# avoid creating zero rated couples
module CoupleRaterHelper
  # returns two random unique elements from
  # the array or returns nil.  The elements
  # are returned as Pictures which are possible
  # newly created.
  def get_two_random_friends(friends)
      if(friends.size >=2)
        f = friends.clone      
        friend_id1= f.delete(f.rand).to_i
        friend_id2= f.delete(f.rand).to_i
        [Picture.find_or_create(friend_id1),Picture.find_or_create(friend_id2)]	
      else
	nil
      end
  end

  # If we want to avoid showing couples
  # with 0 ratings we could use a class
  # like this and take advantage of 
  # ruby's dynamic types
  class FakeCouple
    attr_accessor :picture1
    attr_accessor :picture2
 
    def initialize (pic1, pic2)
	@picture1 = pic1
  	@picture2 = pic2
    end

    def user
	nil
    end
  end
end
