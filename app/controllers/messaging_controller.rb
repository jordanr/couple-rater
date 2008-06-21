# include messages methods, see $RAILS_HOME/lib/facebook_publisher.rb
require 'facebooker_publisher.rb'

# Messaging handles interaction with our messaging library templates
# to send feed stories and the like about user action.  Does not
# have any views associated directly with it on the canvas page.
# Does have views associated with the profile box.
class MessagingController < ApplicationController
include FacebookUser
  ensure_application_is_installed_by_facebook_user

  # update your profile manually
  def profile
    FacebookerPublisher.deliver_profile_for_user(facebook_session.user, facebook_session.user)
    flash[:notice] = "Check your profile. It should be updated."
    redirect_to(:controller=>"couple_rater", :action => "browse")
  end

  # sends message for a poke event
  def poke
     from = facebook_session.user
     from_user = User.find_by_fb_id(from.to_i)
     to_user= User.find_by_fb_id(params[:who])
     to = create_user(to_user) # see messaging helper
     message= ', I am poking you from <a href="'+ url_for({:controller=>"couple_rater",:action=>"browse", :only_path=>false})+'" >Couple Rater</a>'
     FacebookerPublisher.deliver_notification(to, from, message)
     FacebookerPublisher.deliver_poke_templatized_news_feed(from, to_user)
     flash[:notice] = '<fb:success> <fb:message> Success </fb:message>'+
		 	'You poked your friend. </fb:success>'
     redirect_to(:controller=>"linking", :action => "picture", :picturelink=>to_user.picture.id)
  end

  # sends message for a like event and updates relationship status  
  def openly_like
     from = facebook_session.user
     from_user = User.find_by_fb_id(from.to_i)
     to_user= User.find_by_fb_id(params[:who])
     to = create_user(to_user) # see messaging helper
     couple = Couple.find_or_create(from_user.picture.id,to_user.picture.id)
     couple.set_like_for(from_user)
     if(couple.both_like?)
	redirect_to(:action=>"both_like",:who=>params[:who], :couple_id=>couple.id)
     else
       message= ', I like your picture on <a href="'+ url_for({:controller=>"couple_rater",:action=>"browse", :only_path=>false})+'" >Couple Rater</a>'
       FacebookerPublisher.deliver_notification(to, from, message)
       FacebookerPublisher.deliver_openly_like_templatized_news_feed(from, to_user)

       flash[:notice] = '<fb:success> <fb:message> Success </fb:message>'+
  	  	 	  'You said you like their picture. </fb:success>'
       redirect_to(:controller=>"linking", :action => "picture", :picturelink=>to_user.picture.id)
     end
  end
  
  # sends message for a both like event
  def both_like
     from = facebook_session.user
     from_user = User.find_by_fb_id(from.to_i)
     to_user= User.find_by_fb_id(params[:who])
     to = create_user(to_user) # see messaging helper
     
     message= ', I like you and you like me on <a href="'+ url_for({:controller=>"couple_rater",:action=>"browse", :only_path=>false})+'" >Couple Rater</a>'
     FacebookerPublisher.deliver_notification(to, from, message)
     FacebookerPublisher.deliver_both_like_templatized_news_feed(from, to_user, params[:couple_id])

     flash[:notice] = '<fb:success> <fb:message> Notification Sent! </fb:message>'+
			  'They like you too!</fb:success>'
     redirect_to(:controller=>"linking", :action => "couple", :couplelink=>params[:couple_id])
   end

   # Sends mini feed stories to both users of a 10 on a couple
   # they are in.  Both members of the couple must be users.
   def ten
	coup = Rating.find(params[:rating_id]).couple
  	one = create_user(coup.picture1.user)
  	two = create_user(coup.picture2.user)
  	if(!one.nil?)
          FacebookerPublisher.deliver_ten_mini_feed(one, coup.picture2.user)
 	end
	if(!two.nil?)
          FacebookerPublisher.deliver_ten_mini_feed(two, coup.picture1.user)
  	end
        redirect_to({:controller=>"couple_rater", :action => "browse", :rating_id=>params[:rating_id], :gender=>params[:gender], :network=>params[:network]})
   end
end
