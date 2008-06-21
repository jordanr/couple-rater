# Handles google adsense
class AdsController < ApplicationController
  def sidebar_adsense
    # given by our google.com/adsense account
    advert = '<script type="text/javascript"><!--
	google_ad_client = "pub-3888272218030473";
	/* 120x240, created 5/22/08 */
	google_ad_slot = "1265740537";
	google_ad_width = 120;
	google_ad_height = 240;
	//-->
	</script>
	<script type="text/javascript"
	src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
	</script>'	
    render :text => "<html> <body> #{advert} </body> </html>"
  end

  def adsense
    # given by our google.com/adsense account
    advert = '<script type="text/javascript"><!--
	google_ad_client = "pub-3888272218030473";
	/* 468x60, created 5/16/08 */
	google_ad_slot = "6602419635";
	google_ad_width = 468;
	google_ad_height = 60;
	//-->
	</script>
	<script type="text/javascript"
	src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
	</script>'
    render :text => "<html> <body> #{advert} </body> </html>"
  end
end
# another
#    advert =  '<script type="text/javascript"><!--
#		google_ad_client = "pub-3888272218030473";
#		/* 728x90, created 5/8/08 */
#		google_ad_slot = "4991245393";
#		google_ad_width = 728;
#		google_ad_height = 90;
#		//-->
#		</script>
#		<script type="text/javascript"
#		src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
#		</script>'
#   render :text => "<html> <body> #{advert} </body> </html>"
#  end
#end
