module Facebooker
  class Service   
    def post_with_api_logging(params)  
      unless(RAILS_ENV == "production")
        RAILS_DEFAULT_LOGGER.debug(" Posting to #{url} #{params.inspect} ")
      end
      return post_without_api_logging(params)     
    end
    alias_method_chain :post, :api_logging
  end
   
  class Parser
    class <<self
       
      def parse_with_logging(api_method,response)
        unless(RAILS_ENV == "production")
          RAILS_DEFAULT_LOGGER.debug(" Return value #{response.body}")
        end
        return parse_without_logging(api_method, response)     
      end
      alias_method_chain :parse, :logging
    end
  end
end
