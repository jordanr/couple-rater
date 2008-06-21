require 'helpers.rb'

# Methods added to this helper will be available to all templates in the application.
# Here, we give some handy methods for creating standardized couple and picture css
# boxes, handle random advertizing, and really importantly handle problem with non
# viewable photos.  Whenever we have a photo that won't be seen because of facebook
# privacy settings we insert in the profile picture of the user.  Now this profile pic
# may also be unseeable by privacy settings but then at lease we get a question mark
# instead of just a blank.
module ApplicationHelper
include Helpers
  # this appears beside the pictures of browse matches only when you first get to the page
  def sidebar_google_ad
    content_tag("fb:iframe",nil ,  :scrolling => "no", :frameborder => 0 ,
      :width => 100, :height => 300,
      :src => url_for(:controller => "ads", :action => "sidebar_adsense",
               :canvas => false, :only_path => false))
  end

  # this appears in our footer
  def google_ad
    content_tag("fb:iframe",nil ,  :scrolling => "no", :frameborder => 0 ,
      :width => 468, :height => 60,
      :src => url_for(:controller => "ads", :action => "adsense",
               :canvas => false, :only_path => false))
  end

  def social_media_ad
        '<fb:iframe
                src="http://ads.socialmedia.com/facebook/monetize.php?
                width=645&height=60&pubid=ebf63f19b4ce50f09afe20470e758cc7" border="0"
                width="645" height="60" name="socialmedia_ad" scrolling="no" 
	frameborder="0"></fb:iframe>'
  end

  def rotate_ad
    ad_type_methods = [:google_ad,:social_media_ad]
    ad_method = ad_type_methods[rand(ad_type_methods.length)]
    self.send(ad_method)
  end

  # our css we reference in our layout
  def cr_css
    '<style>
	.stats {
	float: right;
	font-weight: bold;
	vertical-align: middle;			
	}		

        .border {
		border:1px solid #B7B7B7;
	}
	
	.loose_border {
		border:1px solid #B7B7B7;
		padding:10px 10px;
		background-color: white;
	}	
	
	.loose_border:hover{
		background-color: rgb(255,255,121);
	}

	.loose_border_noHover{
		border:1px solid #B7B7B7;
                padding:10px 10px;
                background-color: white;
	}
 	
	.ratings:hover{
		border:3px solid #B7B7B7;
		padding: 8px;
	}

	.ratings {
		border:1px solid #B7B7B7;
		clear: both;
		padding: 10px;
		margin: 10px;
		height: 170px;
		font-family: "lucida grande",tahoma,verdana,arial,sans-serif;
		color:#333333;	
		background-color: #E0E0FF;	
	}
	

	.checkBox{
		font-family: "lucida grande",tahoma,verdana,arial,sans-serif;
		font-size: 15px;
		margin-top:10px;
	}

	.submitButton{
		background-color: #FFAAAA;
		font-weight:bold;
		font-size:20px;
		margin-top:10px;

	}
	

	.leftColumn{
		float:left;
	}

	

	legend{
		font-family: "lucida grande",tahoma,verdana,arial,sans-serif;
		border:1px solid #B7B7B7;
		font-size: 24px;

	}

	.couple {	
		float: left;
		vertical-align: middle;	
	}

	.pic {
		width: 33%;
		float: left;
		vertical-align: middle;	
	}
	
	.average{
		font-family: "lucida grande",tahoma,verdana,arial,sans-serif;
		float: right;
		font-size: 30pt;
		font-weight: bold;
		vertical-align: middle;			
	}
	
	.someText{
		font-family: "lucida grande",tahoma,verdana,arial,sans-serif;
		float: right;
		font-size: 25pt;
		font-weight: bold;
		vertical-align: middle;	
		width: 66%;
	}
	
	
	
	
	.numOfVotes{
		font-size: 24pt;
		vertical-align: middle;
	}
	
	.number{
		border:1px solid #DDDDDD;
	}
	
	#titleHead{
		margin: 1em;
	}
        .picky {
               max-height: 300px;
               min-height: 100px; 
               max-width: 200px;    
               min-width: 100px;     
        }   
    </style>'
  end  

  # to make a linking couple
  def fb_couple(couple, pic_options={}, span1_options={:style=>"float:left;"},

					 span2_options={:style=>"float:left;"},
					 c_options={:style=>"float:left;", :class=>"loose_border"}, 
					a_options={}, insert=" ")
    pic1 = couple.picture1
    pic2 = couple.picture2
    pic1_options = pic_options.clone
    pic2_options = pic_options.clone
    a_options.merge!(:href=>url_for({:controller=>'linking',:action=>'couple',:couplelink=>couple.id.to_s}) )
    content_tag(:span,
		content_tag(
			:span, 
			content_tag(:a, fb_profile_pic_or_photo(pic1.fb_id,pic1.user_or_fake_user.fb_id,pic1_options),stringify_vals(a_options)),
			stringify_vals(span1_options) 
		) + insert +
		content_tag(
			:span, 
			content_tag(:a, fb_profile_pic_or_photo(pic2.fb_id,pic2.user_or_fake_user.fb_id,pic2_options),stringify_vals(a_options)),
			stringify_vals(span2_options) 
		),
		stringify_vals(c_options)
    )
  end

  # use this function so we can link pictures to a "picture profile" page
  def fb_picture(picture, options={}, span_options={}, a_options={})
    span_options.merge!(:class=>"loose_border", :style=>"float:left")
    a_options.merge!(:href=>url_for({:controller=>'linking',:action=>'picture',:picturelink=>picture.id.to_s}) )
    content_tag(
	:span, 
	content_tag(:a, fb_profile_pic_or_photo(picture.fb_id,picture.user_or_fake_user.fb_id,options),stringify_vals(a_options)),
	stringify_vals(span_options) 
    )
  end

  # use this function so to make an onclick picture to change the user's
  # active coupling picture.  Used on the "see_pictures" view.
  def fb_changable_photo(pid, options={})
    '<span id="photo" class="loose_border picky" style="float:left;" >' +
    	'<form action='+url_for(:controller=>'users',:action=>'change_picture')+ ' method="POST" style="display:inline">' +
  	    '<input type="hidden" name="choice" value='+pid.to_s + ' />' +
      	    '<fb:submit>' + '<span>' +
      	    	fb_profile_pic_or_photo(pid, 0, options) + 
			'</span>' + '</fb:submit>'+
        '</form>' +
    '</span>'
  end

  # I am replacing the facebooker function so
  # we can use the class attribute and resize photos
  def fb_photo2(photo, options={})
	# options.assert_valid_keys(FB_PHOTO_VALID_OPTION_KEYS)
        options.merge!(:pid => cast_to_photo_id(photo))
        validate_fb_photo_size(options)
        validate_fb_photo_align_value(options)
        tag("fb:photo", stringify_vals(options))
  end

  # to deal with whether the picture is a profile or 
  # really a photo.  Also resizes.
  def fb_profile_pic_or_photo(pid,uid,options={})
    # chooses between a profile picture and photo 
	#size = options[:size]
    if(options[:size]=="normal")
       options.merge!(:class=>"picky border")
    else
       options.merge!(:class=>"border")  
    end
    if(pid == uid)
      options.merge!(:linked=>'false')
      fb_profile_pic(uid,options)
    else
	fb_photo_or_question_mark(uid, pid,options)
    end
  end	

  # handles if the photo cannot be seen after all that
  # and we have to go back to a profile picture
  def fb_photo_or_question_mark(uid,pid,options={})
 	'<fb:if-can-see-photo pid='+pid.to_s+' >' +
		fb_photo2(pid,options) +
	'<fb:else>' + fb_profile_pic(uid,options)+ '</fb:else>
	</fb:if-can-see-photo>'
  end

  # do we use this even. we do have a model function for it also.
  def fb_picture_is_photo?(picture)
	(picture.user_or_fake_user.fb_id!=picture.fb_id)
  end
end
