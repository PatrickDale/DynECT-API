require 'rest_client'
require 'json'

module Dyn
  class DynApi
    def initialize(api_key, endpoint = 'http://emailapi.dynect.net/rest/json/reports/')
      @api_key = api_key
      @endpoint = endpoint
    end
  
    def count_opened_between(options = {})
      action = 'opens/count'
      data = opened_between(options, action)
      data['response']['data']['count']
    end 
  
    def unique_count_opened_between(options = {})
      action = 'opens/count/unique'
      data = opened_between(options, action)
      data['response']['data']['count']
    end
 
    def opened_between(options = {}, action = nil)
      if not action
        action = 'opens'
      end
      get_request(action, options)
    end

    def get_outgoing_email_addresses(options = {})
      action = 'opens'
      data = opened_between(options, action)
      email_list = Array.new
      data['response']['data']['opens'].each do |header|
        email_list.push header['emailaddress']
      end
      return email_list
    end

    def number_of_emails_seen(options = {}, action = nil)
      count_emails_read_with_type(opened_between(options, action), 'seen')
    end

    def number_of_emails_skimmed(options = {}, action = nil)
      count_emails_read_with_type(opened_between(options, action), 'skimmed')
    end

    def number_of_emails_read(options = {}, action = nil)
      count_emails_read_with_type(opened_between(options, action), 'read')
    end

    def number_of_emails_by_type(type_of_read, options = {}, action = nil)
      count_emails_read_with_type(opened_between(options, action), type_of_read)
    end

    def count_emails_read_with_type(json_data, type_of_read)
      previous_user = nil
      stage = nil
      count = 0
      if json_data
        json_data['response']['data']['opens'].each do |post|
          if post['stage'] == type_of_read
            count += 1
          end   
        end
      end
      return count
    end

    def get_request(action, params={})
      params['apikey'] = @api_key
      begin
        parse_response(RestClient.get("#{@endpoint}/#{action}" , {params: params}))
      rescue => e
        parse_response(e.response)
      end
    end

    def parse_response(response)
      JSON.parse(response.body)
    end
  end
end