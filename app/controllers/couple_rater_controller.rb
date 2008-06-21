# Facebook Viral Copyright 2008
#
# This controller does the core of couple rater.  Some
# functions layed out below correspond to fbml views
# to be found in app/views/couple_rater/. 
# Other functions have no views.  They correspond to
# form posts.  They redirect back to the main views.
class CoupleRaterController < ApplicationController
include CoupleRaterHelper
  # go to app/views/layouts/couple_rater.fbml.erb to see
  # our layout.  Contains fb css styling,fb dashboard, fb tabs
  layout "couple_rater.fbml.erb"

  # choices -- turn these on and off
  # to add/remove functionality.
  UNIQUE_RATINGS = true
  SEE_QUESTION_MARKS = true
  CREATE_ZERO_RATED_COUPLES = false

  # Refer to app/views/couple_rater/browse.fbml.erb for the view.
  # The user gets a random couple narrowed by various fields.  
  # Also, the user can rate the couple using radio buttons 
  # based on a random prompt.  The user sees the last rated 
  # couple afterwards.
  def browse
    @cr_user = User.find_by_fb_id(facebook_session.user.to_i)
    # we allow people to see question marks but this user disagrees
    if(SEE_QUESTION_MARKS and !@cr_user.see_question_marks)
      if(params[:question_mark_count].to_i > 5)
            flash[:notice] = "<fb:explanation>
                                <fb:message>We couldn't make a couple. </fb:message>
				You might be able to see a couple if you allow 
				<a href= #{url_for(:controller=>"users",:action=>"see_privacy")}>
				question marks</a>.
                          </fb:explanation>"
        redirect_to({:action => "browse", :network=> "invite_friends"})
	return
      else  # nil.to_i casts to 0 in Ruby
	@question_mark_count = params[:question_mark_count].to_i 
      end
    end

    # side bar for last couple
    if(params[:rating_id])
      @rating=Rating.find(params[:rating_id])
      # In the view, we see total and average.
      @last_couple=@rating.couple
    end
   
    # a prompt
    @prompt = Prompt.rand

    # for the form list
    @nets = @cr_user.networks
    if(params[:network].nil?)
	@network = "friends"
    else
       @network = params[:network]
    end
    if(params[:gender])
	@gender = params[:gender]
    elsif(@network== "friends")
	@gender = "bi"
    else
	@gender = @cr_user.default_gender
    end

    # get the random couple
    two_pics = nil
    two_users = nil
    case(@network)
      when "chosen" :
        two_pics = Picture.find(params[:chosen_picture_id1],params[:chosen_picture_id2])		
      when "friends":
        two_pics = get_two_random_friends(facebook_session.user.friends)
      when "anywhere":
        users_to_use = []
        @nets.each {|net| net.users.each {|u| users_to_use.push u if !users_to_use.member? u } }
        user1 = User.findyPeopleFromOrientation(users_to_use, @gender).rand
        two_users = User.findyMatchByOrientation(users_to_use, user1, @gender)
      else
	 if(@cr_user.networks.exists?(@network) )
            active_network =  @cr_user.networks.find(params[:network])
            two_users = active_network.users.findy(@gender)
	 end
    end

    # see if we have enough users
    if(two_users.nil? and two_pics.nil?)
        # accumulate the messages
	flash[:notice]= "" if flash[:notice].nil?
	case(@network)
	  when "chosen":
	    flash[:notice] += "<fb:error> 
				<fb:message>We couldn't make the chosen couple. </fb:message>
				How did that happen?  Please report this bug.
			     </fb:error>"
	  when "friends":
    	    flash[:notice] += "<fb:explanation> 
				<fb:message>You don't have enough friends</fb:message>
				You must have at least 2 friends to rate a friend couple.
			  </fb:explanation>" 
	    redirect_to({:action => "browse", :network=> "anywhere"})
	    return
 	  when "anywhere":
    	    flash[:notice] += "<fb:explanation> 
 				<fb:message>None of your networks have members</fb:message>
			 	You cannot rate any network couples.
			  </fb:explanation>" 
 	  else
	    flash[:notice] += "<fb:explanation> 
				<fb:message>We couldn't make a couple. </fb:message>
				You are the only person in this network/gender group.
			  </fb:explanation>"
	end
        redirect_to({:action => "invite_friends"})
    elsif(two_users.nil?) # we have two pictures
	if(CREATE_ZERO_RATED_COUPLES)
       	  @couple = Couple.find_or_create(two_pics[0].id,two_pics[1].id)
	  @fake_couple = false
   	else
	  @couple = FakeCouple.new(two_pics[0],two_pics[1])
	  @fake_couple =true
	end
    else # we have at least 2 users
	if(CREATE_ZERO_RATED_COUPLES)
      	  @couple = Couple.find_or_create(two_users[0].picture.id,two_users[1].picture.id)
	  @fake_couple = false
   	else
	  @couple = FakeCouple.new(two_users[0].picture,two_users[1].picture)
	  @fake_couple =true
	end
    end
  end

  # Rate handles the submitted form from browse.  Creates a rating by the
  # user on the couple.  Creates the couple if necessary.  Redirects back
  # with the narrowing options and the resulting rating.  browse then
  # displays the resulted rating created here and brings up a new
  # random couple based on the narrowing options.
  def rate
    cr_user = User.find_by_fb_id(facebook_session.user.to_i)
    # submitted by clicking on radio buttons
    if(params[:rating])
        if(CREATE_ZERO_RATED_COUPLES and params[:couple_id])
            couple = Couple.find(params[:couple_id])
 	elsif(!CREATE_ZERO_RATED_COUPLES and params[:picture_id1] and params[:picture_id2])
	    couple = Couple.find_or_create(params[:picture_id1], params[:picture_id2])
	else # something screwy
	    flash[:notice] = "<fb:explanation><fb:message>Rating Failed! 
					  </fb:message> How did you get here?
	 		    </fb:explanation>"
            redirect_to({:action => "browse"})
	    return
 	end
	
	if(couple.both_pictures_are_users?)
	  couple.refresh_networks
        else
   	      message = "One of your friends in the last couple does not have Couple Rater."
	      flash[:notice] = "<fb:explanation><fb:message> #{message}
			        </fb:message><a href= #{url_for(:action=>"invite_friends")} >
				Invite them so they can see your rating!</a>
	 		        </fb:explanation>"
	end

        # add the rating/update our couple
        if(UNIQUE_RATINGS)
          Rating.delete_all({:user_id=>cr_user.id,:couple_id=>couple.id})
        end    
        rating = Rating.create(:couple_id => couple.id, :user_id=>cr_user.id, :rating=> params[:rating])
        couple = Couple.find(couple.id).refresh
	
	params[:network]="friends" if(params[:network]=="chosen")


	# publish mini feed stories on tens
 	if(couple.both_pictures_are_users? and params[:rating].to_i==10)
          redirect_to({:controller=>"messaging", :action => "ten", :rating_id=>rating.id, :gender=>params[:gender], :network=>params[:network]})
   	else
          redirect_to({:action => "browse", :rating_id=>rating.id, :gender=>params[:gender], :network=>params[:network]})
	end
    # submitted by button
    elsif(params[:filtersubmit])
        # Allows gender-viewing preferences to remain after clicking radio buttons
        redirect_to({:action => "browse", :gender=>params[:gender], :network=>params[:network]})
    else
   	flash[:notice] = '<fb:error>Rating Failed! How did you get here? </fb:error>'
        redirect_to :action => "browse"
    end
  end

  # Shows all couples in our database sorted
  # by the below four categories.  We maybe
  # should limit these couples by network or
  # else to stop too many question marks and
  # given more relevant "Couplistics".
  def see_globals
    @newest = Couple.newest
    @recent = Couple.most_recent
    @rated =  Couple.most_rated
    @highest= Couple.highest_rated 
  end

  # The user can invite his/her friends 
  # to add Couple Rater.  Does not show
  # already added friends.
  def invite_friends
    @fb_user= facebook_session.user
    @friends_with_app = @fb_user.friends_with_this_app
  end
end
