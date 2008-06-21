# An attempt at extending Facebooker's rails helpers
module Helpers
  def fb_css
    '<style>
	.lists th {
	     text-align: left;
	     padding: 5px 10px;
	     background: #6d84b4;
	}

	.lists .spacer {
	     background: none;
	     border: none;
	     padding: 0px;
	     margin: 0px;
	     width: 10px; 
	}

	.lists th h4 { float: left; color: white; }
	.lists th a { float: right; font-weight: normal; color: #d9dfea; }
	.lists th a:hover { color: white; }

	.lists td {
	     margin:0px 10px;
	     padding:0px;
	     vertical-align:top;
	}

	.lists .list {
	     background:white none repeat scroll 0%;
	     border-color:-moz-use-text-color #BBBBBB;
	     border-style:none solid;
	     border-width:medium 1px;
	}
	.lists .list .list_item { border-top:1px solid #E5E5E5; padding: 10px; }
	.lists .list .list_item.first { border-top: none; }

	.lists .see_all {
	     background:white none repeat scroll 0%;
	     border-color:-moz-use-text-color #BBBBBB rgb(187, 187, 187);
	     border-style:none solid solid;
	     border-width:medium 1px 1px;
	     text-align:left;
	}

	.lists .see_all div { border-top:1px solid #E5E5E5; padding:5px 10px; }
	
	</style>'	
  end

  def fb_tr(&block)
	content = capture(&block)
	concat(content_tag(:tr,content),block.binding)
  end
	
  def fb_th(title,url,label, options={} )
	options.merge!(:href=>url)
	content_tag(:th,content_tag(:h4,title)+ 
			content_tag(:a,label,stringify_vals(options))
		   ) 
  end

  def fb_th_spacer(options={})
	options.merge!(:class=>"spacer")
      	tag(:th, stringify_vals(options))
  end

  def fb_td(options={},&block)
	options.merge!(:class=>"list")
	content = capture(&block)
        concat(content_tag(:td,content,stringify_vals(options)), block.binding)
  end
  
  def fb_td_spacer(options={})
	options.merge!(:class=>"spacer")
      	tag(:td, stringify_vals(options))
  end

  def fb_tf(url, label,td_options={},a_options={})
	td_options.merge!(:class=>"see_all")
	a_options.merge!(:href=>url)
	content_tag(:td,
	   content_tag(:div,
		content_tag(:a,label,stringify_vals(a_options)) 
	   ), stringify_vals(td_options)
	)
  end

  def fb_tf_spacer(options={})
	fb_td_spacer(options)
  end

  def fb_table(options={}, &block)
	options.merge!(:class=>"lists",:cellspacing=>"0", :border=>"0")
	content = capture(&block)
	content_tag(:div,
		concat(content_tag(:table, content,stringify_vals(options) ),
		       block.binding
		)
	)
  end

  def fb_first_list_item(options={},&block)
	content = capture(&block)
	options.merge!(:class=>'list_item.first clearfix')
	concat(content_tag(:div,content,stringify_vals(options)),block.binding)
  end
  def fb_list_item(options={}, &block)
	content = capture(&block)
	options.merge!(:class=>'list_item clearfix')
	concat(content_tag(:div,content,stringify_vals(options)),block.binding)
  end
end
