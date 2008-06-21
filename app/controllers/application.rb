# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

# log our api calls
require 'extensions.rb'
require 'digest/md5'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  # I had a lot of trouble with this filter so I'm commenting it out
  # protect_from_forgery :except => [:uninstall, :attachment] #, :secret => 'f86bcca0d7da0aafe935c1f6582c221a'

  # from facebooker,
  ensure_application_is_installed_by_facebook_user :except => [:uninstall]
#  ensure_authenticated_to_facebook :except => [:uninstall]

  # when a user authenticates to facebook this before filter redirects
  # the user back to a fbml canvas page instead of to html on our server.
  before_filter :redirect_if_auth_key
  
  # this filter handles uninstalls
  before_filter :verify_uninstall_signature, :only => [:uninstall]
  
  # keeps the user inside facebook when they first install and
  # also allows us to add them to our User table
  def redirect_if_auth_key
    if( params[:auth_token])
      redirect_to( url_for(:action => "install", 
		 	  :canvas => true, :only_path => false))
    end
  end   

  # Checks to see if the signature follows facebook's
  # algorithm.
  def verify_uninstall_signature
    signature = ''
    keys = params.keys.sort
    keys.each do |key|
      next if key == 'fb_sig'
      next unless key.include?('fb_sig')
      key_name = key.gsub('fb_sig_', '')
      signature += key_name
      signature += '='
      signature += params[key]
    end
    signature += ENV['FACEBOOK_SECRET_KEY']
    calculated_sig = Digest::MD5.hexdigest(signature)
    #logger.info "\nUNINSTALL :: Signature (fb_sig param from facebook) :: #{params[:fb_sig]}"
    #logger.info "\nUNINSTALL :: Signature String (pre-hash) :: #{signature}"
    #logger.info "\nUNINSTALL :: MD5 Hashed Sig :: #{calculated_sig}"
    if calculated_sig != params[:fb_sig]
      #logger.warn "\n\nUNINSTALL :: WARNING :: expected signatures did not match\n\n"
      return false
    else
      #logger.warn "\n\nUNINSTALL :: SUCCESS!! Signatures matched.\n"
    end
    return true
  end

  # We create the user if new, cache the session key for new or old, and
  # redirect to main.
  def install
    fb_user = facebook_session.user    
    old = User.exists?(:fb_id=>fb_user.to_i)
    cr_user= User.find_or_create(fb_user.to_i,fb_user.sex, fb_user.first_name, 
			fb_user.last_name, fb_user.affiliations, facebook_session.session_key)
    cr_user.update_attribute(:session_key,facebook_session.session_key)
    if(old)
      flash[:notice] = "<fb:explanation>
			<fb:message>Welcome Back "+cr_user.first_name.to_s +
			"</fb:message></fb:explanation>"
    else
      flash[:notice] = "<fb:success>
			<fb:message>Welcome</fb:message>
			 Thanks for installing Couple Rater.</fb:success>"
    end
    redirect_to(:controller=>"couple_rater", :action => "browse")
  end

  # Pinged when facebook user uninstalls our app and
  # we purge them from the database.
  def uninstall
    @fb_id = params[:fb_sig_user]
    @user = User.find_by_fb_id(@fb_id)
    @user.kill if @user
    render :nothing => true; return
  end
end
