namespace :profile do
  desc "Refresh the facebook cache of our users' profile fbml"
  task(:update=> :environment) do
        users = User.find(:all)
        users.each { |user|
         p user.first_name + " " + user.last_name
         if(!user.session_key.nil?)
 	  p "> ACTIVE"
          facebook_session = Facebooker::Session.new(ENV['FACEBOOK_API_KEY'], ENV['FACEBOOK_SECRET_KEY'])
          facebook_session.secure_with!(user.session_key,user.fb_id,0)
          begin
            if(!user.session_key.nil?)
               FacebookerPublisher.deliver_profile_for_user(facebook_session.user, facebook_session.user)
            end
          rescue
            # on any error we will eliminate this user and continue on
	    p "> ERROR!"
            user.update_attribute(:session_key,nil)
            retry
          end
         end
        }
        p "All updated"
  end
  
  #TODO:
  desc "Send a news feed story to each user profile"
  task(:news_feed=> :environment) do
        users = User.find(:all)
        users.each { |user|
         p user.first_name + " " + user.last_name
         if(!user.session_key.nil?)
 	  p "> ACTIVE"
          facebook_session = Facebooker::Session.new(ENV['FACEBOOK_API_KEY'], ENV['FACEBOOK_SECRET_KEY'])
          facebook_session.secure_with!(user.session_key,user.fb_id,0)
          begin
            if(!user.session_key.nil?)
               #FacebookerPublisher.deliver_profile_for_user(facebook_session.user, facebook_session.user)
            end
          rescue
            # on any error we will eliminate this user and continue on
	    p "> ERROR!"
            user.update_attribute(:session_key,nil)
            retry
          end
         end
        }
        p "All updated"
  end   
end
