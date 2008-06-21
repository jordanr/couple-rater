# I did not know what to call this controller, so
# I can up with the kind of abstract name "linking."
# Basically, it handles all the unorganized links
# around Couple Rater.  The links that don't have
# tabs and labels and are not real obvious.  Linking views
# are the VIP section of our website.  You're probably a
# valued user if you know about them all.  The views
# are the backdoor entrances and smoke rooms of Couple Rater.
class LinkingController < ApplicationController
  layout "couple_rater.fbml.erb"

  # Displays a couple profile
  def couple
    @couple = Couple.find(params[:couplelink])
  end

  # Displays a picture profile
  def picture
    @cr_user = User.find_by_fb_id(facebook_session.user.to_i)
    @picture = Picture.find(params[:picturelink])
  end

  # Displays all the ratings by a user.
  def user_ratings
    @user = User.find(params[:user_id])
  end

  # Shows all the ratings on a couple
  def couple_ratings
    @couple = Couple.find(params[:couple_id])
  end

  # Shows all the couples in network
  def couple_network
    @net = Network.find(params[:network_id])
  end

  # Show all the users in a network
  def user_network
    @net = Network.find(params[:network_id])
  end     	

  # Linked from the global statistics page.  Show all the couples 
  # of the passed statistic type.
  def see_all
    if(!params[:order])
	flash[:notice] = '<fb:error><fb:message> Error! </fb:message>
			 How did you get here? </fb:error>'
  	redirect_to :controller=>"couple_rater", :action=>"see_globals"
	return
    end
    cr_user = User.find_by_fb_id(facebook_session.user.to_i)
    case(params[:order].to_s)
    when "newest"
	@see_all = Couple.newest
    when "active"
        @see_all = Couple.most_recent
    when "most_rated"
        @see_all =  Couple.most_rated
    else
       @see_all= Couple.highest_rated
    end
  end

  # redirects user to main rate page with
  # the chosen two pictures to rate
  def rate_chosen_couple
    if(params[:chosen_picture_id1] and params[:chosen_picture_id2])
        flash[:notice] = '<fb:explanation>
                          <fb:message> You have chosen this non-random couple
                      </fb:message></fb:explanation>'
        redirect_to(:controller=>"couple_rater",:action=>"browse",
			:chosen_picture_id1=>params[:chosen_picture_id1],
			:chosen_picture_id2=>params[:chosen_picture_id2],
			:network=>"chosen")
    else
        flash[:notice] = '<fb:error> Error
                          <fb:message> How did you get here?
                          </fb:message></fb:error>'
        redirect_to(:controller=>"couple_rater",:action=>"browse")
    end
  end

  # redirects user to given user's see matches page
  def see_matches_of_chosen_user
    if(params[:chosen_user_id])
        cr_user = User.find(params[:chosen_user_id])
        flash[:notice] = '<fb:explanation> 
                          <fb:message> Matches of ' + cr_user.first_name.to_s +
                          '</fb:message></fb:explanation>'
    else
        flash[:notice] = '<fb:error> Error
                          <fb:message> How did you get here?
                          </fb:message></fb:error>'
    end
    redirect_to(:controller=>"users",:action=>"see_matches", :chosen_user_id=>params[:chosen_user_id])
  end

  # Sets the secret for the user on the given couple and
  # if they both like each other, sends messaging
  def set_secret
    actor = User.find_by_fb_id(facebook_session.user.to_i)
    victim = User.find(params[:who])
    couple = Couple.find_or_create(actor.picture.id,victim.picture.id)
    couple.set_secret_for(actor)
    # send messages if both like
    if(couple.both_like?)
	redirect_to(:controller=>"messaging",:action=>"both_like",:who=>victim.fb_id, :couple_id=>couple.id)
    else
        flash[:notice] = '<fb:success> <fb:message>Success</fb:message> 
			We will keep your secret save.</fb:success>'
        redirect_to(:controller=>"linking",:action=>"picture",:picturelink=>victim.picture.id)
    end
  end

  # called by popup dialog on main browse/rate page to
  # flip the user's preference on not seeing or seeing
  # question marks
  def change_question_mark_setting
    cr_user = User.find_by_fb_id(facebook_session.user.to_i)
    cr_user.flip_question_mark_setting
    if(cr_user.see_question_marks)
	message = "Ok, we will show them.  You can change it anytime you like."
    else
    	message = "Ok, no more question marks!  You can always change back if you find it too limiting."
    end
    flash[:notice] = "<fb:success> <fb:message> Preference Saved
			</fb:message> #{message}
			</fb:success>"
    redirect_to(:controller=>"couple_rater",:action=>"browse")
  end	

  # Redirects the main page and gives a success message 
  # after user invite actions.
  def invite_friends_redirect
    flash[:notice] = "<fb:success> <fb:message> Success
			</fb:message> Invite Sent!
			</fb:success>"
    redirect_to(:controller=>"couple_rater",:action=>"browse")
  end

  def make_new_prompt
    cr_user = User.find_by_fb_id(facebook_session.user.to_i)
    cr_user.prompts.create(:text=>params[:prompt]) if(params[:prompt])
    flash[:notice] = "<fb:success> <fb:message> Success
			</fb:message> New prompt created!
			</fb:success>"
    redirect_to(:controller=>"couple_rater",:action=>"browse")
  end
end
