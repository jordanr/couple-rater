module FacebookUser
  def create_user(user)
    if(!user.session_key.nil?)
          facebook_session = Facebooker::Session.new(ENV['FACEBOOK_API_KEY'], ENV['FACEBOOK_SECRET_KEY'])
          facebook_session.secure_with!(user.session_key,user.fb_id,0)
	  facebook_session.user
    end
    nil
  end
end
