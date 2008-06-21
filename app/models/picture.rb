# Users have many pictures.  Then two
# pictures are grouped into couples.
class Picture < ActiveRecord::Base
	belongs_to :user

	#has_many :couples # actually shares many? won't work	
        # You must find a way to handle this has_two relationship
        # and do a joined table.
	def couples(gender="all")
	  if(gender=="all")
	    Couple.find_by_sql(["SELECT * FROM couples WHERE picture_id1=? OR picture_id2=?", id, id])
	  elsif(gender=="boys")
	    all = Couple.find_by_sql(["SELECT * FROM couples WHERE picture_id1=? OR picture_id2=?", id, id])
	    all.delete_if { |couple| 
			male = couple.not_me(id).user_or_fake_user.gender 
			(male.nil? || !male)
			}
	  elsif(gender=="girls")
	    all = Couple.find_by_sql(["SELECT * FROM couples WHERE picture_id1=? OR picture_id2=?", id, id])
	    all.delete_if { |couple| 
			male =couple.not_me(id).user_or_fake_user.gender 
			(male.nil? || male) 
			}
	  else
	    []
     	  end
	end

 	# gives the most recent couples of this picture to the profile box
        def recent_couples
	  Couple.find_by_sql(["SELECT * FROM couples WHERE picture_id1=? OR 
			picture_id2=? ORDER BY updated_at DESC", id, id])
	end

	# We find or create a userless picture.
	def Picture.find_or_create(fb_pid)
	  if(Picture.exists?(:fb_id=>fb_pid) )
	    pic = Picture.find_by_fb_id(fb_pid)
	  else
	    pic = Picture.create(:fb_id=>fb_pid)
	  end
 	  pic
	end

 	# Is the user still on his default profile picture?
	def profile_pic?
	  (fb_id==user.fb_id)
 	end

 	# We make sure that we can do everything with
  	# a userless picture that we can with real
 	# user's picture.  Use dynamic typing.
	def user_or_fake_user
	   if(user_id.nil?)
		FakeUser.new(fb_id, id)
	   else
		user
	   end
 	end

	# Tells if we have a fake or real user
	def user?
	   !user_id.nil?
	end

	# We want to keep our code the same but
	# allow for non users to have pictures so
	# we can use ruby's dynamic types here
	class FakeUser
	    attr_accessor :picture_id
	    attr_accessor :fb_id

	    def initialize (fb_uid, pid)
		@fb_id = fb_uid
		@picture_id = pid
	    end
	
	    def picture
		Picture.find(picture_id)
	    end
		
	    def networks
	        []
	    end

	    def ratings
	        []
	    end
	    
    	    def non_friends_can_see_my_matches
		false
	    end
    	    def friends_can_see_my_matches
		false
	    end

	    def pictures
	        [picture]
	    end
	    
  	    def gender
		nil
	    end
 	 end
end
