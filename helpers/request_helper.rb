require 'json'
require 'httparty'

class RequestError < Exception
end

class RequestHelper
  
  def initialize
    @@valid_request_types = ['GET', 'POST']
  end

  def request(type, url, valid_response_codes=[200, 201], **options)
    query = options[:query] || nil
    headers = options[:headers] || nil
    body = options[:body] || nil
    case type
    when 'GET'
      response = HTTParty.get(url, :query => query, :headers => headers)
    when 'POST'
      response = HTTParty.post(url, :query => query, :headers => headers, :body => body)
    else
      raise RequestError, 'Invalid request type "%s". Valid types are "%s"' %s[type, @@valid_request_types.join(',')] 
    end
    if !valid_response_codes.include? response.code 
      puts response.body.class
      raise RequestError, 'Request "%s" returned with status code "%s" and message "%s" and body "%s"' %[url, response.code.to_s, response.message.to_s, response.body]
    end
    return JSON.parse response.body;
  end

end
