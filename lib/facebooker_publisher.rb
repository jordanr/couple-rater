# Facebook Viral 2008

# In this class, we write our messages.  We have,
## News Feeds (TODO)
### Publishes in the user's private view.  Friends will
### not see these stories.

## Mini Feeds  (TODO)
### Publishes in the user's public view.  Friends may see
### these messages if they look at the user's profile.

## Templatized feeds (in progress)
### Publishes in the user's public mini-feed and also
### possibly in some of the user's private news feeds.
### Facebooker says this message is the main way to
### be successful in speading an application.

## Profile (done)
### Seen on the main profile page of the user.
### Is a widget which you can put in lots of fbml.

## Email (not done but not todo?)
### Email from facebook.  Seems creepy to me.

# With these messaging types, we define what we
# want to say here.  What text will show up in a 
# mini-feed message about a user getting a 10?
# And so on.

require 'singleton'
class FacebookerPublisher < Facebooker::Rails::Publisher
include Singleton
  # for someone poking someone else
  def poke_templatized_news_feed(user, who)
    send_as :templatized_action
    from(user)
    title_template "{actor} poked the picture of <fb:name uid={victim_uid}/>."
    title_data({:victim_pid=>who.picture.id, :victim_uid => who.fb_id})
    body_template("Be sure to check out {name}. ")
    body_general("#{link_to("Couple Rater", {:controller=>"couple_rater",:action=>"browse",:only_path=>false})} 
			is a place to rate couples.")
    body_data(:name => "Couple Rater")
    image_1(image_path("the_big_c.png"))
    image_1_link(url_for(:controller=>"couple_rater",:action=>"browse",:only_path => false))
  end

  #  someone openly liking
  def openly_like_templatized_news_feed(user, who)
    send_as :templatized_action
    from(user)
    title_template "{actor} likes the picture of <fb:name uid={victim_uid}/>."
    title_data({:victim_pid=>who.picture.id, :victim_uid => who.fb_id})
    body_template("Be sure to check out {name}. ")
    body_general("#{link_to("Couple Rater", {:controller=>"couple_rater",:action=>"browse",:only_path=>false})} 
			is a place to rate couples.")
    body_data(:name => "Couple Rater")
    image_1(image_path("the_big_c.png"))
    image_1_link(url_for(:controller=>"couple_rater",:action=>"browse",:only_path => false))
  end

  # when a couple finds out they like each other
  # TODO: it would be cool to show the picture of the couple but tough to do
  def both_like_templatized_news_feed(user, who, couple_id)
    send_as :templatized_action
    from(user)
    title_template "{actor} and <fb:name uid={victim_uid}/> both like their picture together."
    title_data({:cid=>couple_id, :victim_uid => who.fb_id})
    body_template("Be sure to check out {name}. ")
    body_general("#{link_to("Couple Rater", {:controller=>"couple_rater",:action=>"browse",:only_path=>false})} 
			is a place to rate couples.")
    body_data(:name => "Couple Rater")
    image_1(image_path("the_big_c.png"))
    image_1_link(url_for(:controller=>"couple_rater",:action=>"browse",:only_path => false))
  end

  # we use this for openly_like, both_like, and poke
  # the text of each message is right now in the linking controller
  def notification(to,from,message)
    send_as :notification
    self.recipients(to)
    self.from(from)
    fbml message
  end

  # run by a rake task by a cron job
  def profile_for_user(user_to_update, user_with_session_to_use)
    send_as :profile
    from user_with_session_to_use
    recipients user_to_update
    # get the users more recent couples
    @pic = User.find_by_fb_id(user_to_update.uid).picture
    @couples = @pic.recent_couples
    fbml = render(:partial =>"/messaging/user_profile.fbml.erb", 
		:locals=> {:pic => @pic, :couples=>@couples})
    profile(fbml)
    action =  render(:partial => "messaging/profile_action.fbml.erb") 
    profile_action(action) 
  end

  def ten_mini_feed(user, who)
    send_as :action
    self.from(user)
    title "Someone rated #{fb_name(user)} a 10! on Couple Rater."
    body "Check out the picture of #{link_to(fb_name(who.fb_id),
	 :controller => "linking", :action => "picture", :picturelink=>who.picture.id)}
	 on #{link_to("Couple Rater",:controller=>"couple_rater",:action=>"browse")}"
    ## RAILS_DEFAULT_LOGGER.debug("Sending mini feed story for user #{user.id}")
  end

  #################### unused skeletons below here####################
  def news_feed(recipients, title, body)
    send_as :story
    self.recipients(Array(recipients))
    title = title[0..60] if title.length > 60
    body = body[0..200] if body.length > 200
    self.body( body )
    self.title( title )
  end

  def email(from,to, title, text, html)
    send_as :email
    recipients(to)
    from(from)
    title(title)
    fbml(html)
    text(text)
  end

end
