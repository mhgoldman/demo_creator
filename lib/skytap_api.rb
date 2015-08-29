require 'logger'
require 'rest-client'
require 'httplog'
require 'recursive_open_struct'

class SkytapAPIObject < RecursiveOpenStruct
  def initialize(obj)
    @data = RecursiveOpenStruct.new(obj, recurse_over_arrays: true)
  end

  def get(url=nil)
    url ||= self.url
    raise 'No URL to get' unless url

    @data = SkytapAPI.get(URI(url || self.url).path)
  end

  def method_missing(method_sym, *args, &block)
    @data.send(method_sym, *args, &block)
  end
end

class SkytapAPI
  MAX_RETRIES = 5
  SLEEP_BETWEEN_RETRIES_SECS = 20

  def self.post(url, body=nil)
    api_call(:post, url, body, 0)
  end

  def self.put(url, body=nil)
    api_call(:put, url, body, 0)
  end

  def self.get(url)
    api_call(:get, url, nil, 0)
  end

  def self.delete(url)
    api_call(:delete, url, nil, 0)
  end

  private

  def self.api_call(method, url, body=nil, retries=0)
    Rails.logger.info("Skytap API Request: Method: #{method}, URL: #{url}, Body: #{body}, Retries: #{retries}")

    @api ||= RestClient::Resource.new(ENV['skytap_api_url'],
      user: ENV['skytap_api_user'],
      password: ENV['skytap_api_key'],
      headers: {accept: :json, content_type: :json}
    )

    uri = URI(url)
    url = uri.path + (uri.query ? "?#{uri.query}" : "")
    url = url[1..-1] if url.start_with?('/')

    begin
      if [:get,:delete].include?(method)
        output = @api[url].send(method)          
      else
        output = @api[url].send(method, body ? body.to_json : nil)
      end
    rescue RestClient::Exception => ex
      if ex.http_code == 423
        raise if retries >= MAX_RETRIES

        Rails.logger.warn("Got busy response... will sleep #{SLEEP_BETWEEN_RETRIES_SECS} seconds and retry")
        sleep SLEEP_BETWEEN_RETRIES_SECS
        self.api_call(method, url, body, retries+1)
      else
        raise
      end
    end

    return nil if method == :delete
    
    resp = JSON.parse(output, symbolize_names: true)
    resp.is_a?(Array) ? resp.map {|obj| SkytapAPIObject.new(obj)} : SkytapAPIObject.new(resp)
  end
end