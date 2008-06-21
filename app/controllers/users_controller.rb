# Handles more user-specific requests.
class UsersController < ApplicationController
  layout "couple_rater.fbml.erb"

  # The user sees his/her best pairings with other 
  # users of Couple Rater. The user can set 
  # whether he/she likes a match.
  def see_matches
   if(params[:chosen_user_id])
	cr_user = User.find(params[:chosen_user_id])
	@chosen = true
   else
   	cr_user= User.find_by_fb_id(facebook_session.user.to_i)
	@chosen = false
   end
   @me_pic = cr_user.picture

   @gender = params[:gender]   
   @network = params[:network]

   if(params[:network] != "all" and cr_user.networks.exists?(params[:network]) and params[:gender])   
     net = cr_user.networks.find(params[:network])
     @matches = net.couples_with_picture(@me_pic.id) & @me_pic.couples(params[:gender])
   elsif(params[:network] !="all" and cr_user.networks.exists?(params[:network]) )
     net = cr_user.networks.find(params[:network])
     @matches = net.couples_with_picture(@me_pic.id)
   elsif(params[:gender])     
     @matches = @me_pic.couples(params[:gender])
   else	
     @matches = @me_pic.couples
   end

   # we can't do this friends when we don't have the facebooker API calls
   if(!@chosen)
     friends = facebook_session.user.friends
     friend_ids = friends.collect { |f| f.to_i }
     @friendship = params[:friendship]
     case(@friendship)
 	when "friends": @matches.delete_if { |couple| !friend_ids.include?(couple.not_me(@me_pic.id).user_or_fake_user.fb_id) }
 	when "non_friends": @matches.delete_if { |couple| friend_ids.include?(couple.not_me(@me_pic.id).user_or_fake_user.fb_id) }
	else # keep all
     end
   end

   @status = params[:status]
   proc = case(params[:status])
	when "love": Proc.new { |couple| couple.both_like? }
  	when "i_like": Proc.new { |couple| (couple.i_openly_like?(@me_pic.id) ) }
	when "they_like": Proc.new { |couple| (couple.i_openly_like?(couple.not_me(@me_pic.id).id) )}
	when "i_secretly_like": Proc.new { |couple| (couple.i_secretly_like?(@me_pic.id) ) }
	when "unknown" : Proc.new { |couple| (!couple.i_like?(@me_pic.id))  }
   	else Proc.new { |couple| true }
   end

   @matches.delete_if { |match| !proc.call(match) } 

   @none = (@matches.nil? || @matches.length==0)
   @nets = cr_user.networks
  end

  # just redirects back with success message and params
  def filter_matches
      flash[:notice] = '<fb:success>
			<fb:message>Success</fb:message>
			These are your matches.</fb:success>'
      redirect_to(:controller => "users", :action => "see_matches", :network=> params[:network], :gender=>params[:gender], :status=>params[:status], 
						:friendship=>params[:friendship])
  end

  # handles changes to liking relationship statuses and
  # then redirect back the see matches.
  def change_matches      
      cr_user= User.find_by_fb_id(facebook_session.user.to_i)
      cr_user.picture.couples.each { |couple|
	if(params[couple.id.to_s])
	 	couple.set_like_for(cr_user, params[couple.id.to_s+"_likes"]=="1" )
		couple.set_secret_for(cr_user,params[couple.id.to_s+"_secret"]=="1" )
	end
      }      
      redirect_to(:controller => "users", :action => "see_matches", :status=>params[:status], :gender=>params[:gender],:network=>params[:network],
									:friendship=>params[:friendship])
  end


  # Shows the friends with app and the friends
  # rated here inside app who may not be users
  def see_friends
    fb_user = facebook_session.user
    @friends_with_app = fb_user.friends_with_this_app
	
    friend_ids = fb_user.friends.collect { |f| f.to_i }
    @friends_rated = Picture.find(:all, :conditions => {:fb_id=>friend_ids} )
  end

  # shows the users profile pictures and allows
  # him/her to choose a new active picture
  def see_pictures
    fb_user = facebook_session.user
    @photos = fb_user.profile_photos
    @user = User.find_by_fb_id(fb_user.uid)
  end

  # handles changes the active picture
  def change_picture
    if(params[:choice].nil?)
      flash[:notice] = '<fb:error>
			<fb:message>Picture Change Failed!</fb:message>
			We could not handle your request.  Please report this bug.
			</fb:error>'
      redirect_to(:action => "see_pictures") 
    else 
      fb_user = facebook_session.user
      cr_user = User.find_by_fb_id(fb_user.to_i)
      cr_user.update_picture(params[:choice])
      flash[:notice] = '<fb:success>
			<fb:message>Success</fb:message>
			You have changed your picture.</fb:success>'
      redirect_to(:controller => "users", :action => "see_privacy")
    end
  end

  # shows the preferences/privacy options 
  def see_privacy
    fb_user = facebook_session.user
    @user = User.find_by_fb_id(fb_user.to_i)
  end

  # handles changes to preferences/privacy
  def change_privacy
    posted_user = params[:user]
    fb_user = facebook_session.user
    user = User.find_by_fb_id(fb_user.to_i)
    user.update_attributes(posted_user)
    flash[:notice] = '<fb:success>
			<fb:message>Success</fb:message>
			You have updated your privacy settings.</fb:success>'
    redirect_to(:controller => "users", :action => "see_privacy")
  end

  # shows networks and updates the network to
  # the current user's affiliations in case
  # he/she added a new facebook network or
  # dropped one
  def see_networks
    fb_user = facebook_session.user
    @cr_user = User.find_by_fb_id(fb_user.to_i)
    @fb_affs = fb_user.affiliations
  end

  # Sets the networks-users to the given ones
  def change_networks
    fb_user = facebook_session.user
    cr_user = User.find_by_fb_id(fb_user.to_i)
    fb_affs = fb_user.affiliations
    cr_user.networks.clear
    fb_affs.each { |affiliation|
        network = Network.find_or_create(affiliation.nid,affiliation.name)
        if(params[network.network])
	  cr_user.networks << network
        end
    }    
    flash[:notice] = '<fb:success>
			<fb:message>Success</fb:message>
			You have updated your networks.</fb:success>'
    redirect_to(:controller => "users", :action => "see_networks")
  end
end
