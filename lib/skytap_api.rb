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

  HttpLog.options[:logger] = Rails.logger
  HttpLog.options[:log_headers] = true

  def self.post(url, body=nil, user=nil, pass=nil)
    api_call(:post, url, body, 0, user, pass)
  end

  def self.put(url, body=nil, user=nil, pass=nil)
    api_call(:put, url, body, 0, user, pass)
  end

  def self.get(url, user=nil, pass=nil)
    api_call(:get, url, nil, 0, user, pass)
  end

  private

  def self.api_call(method, url, body=nil, retries=0, user=nil, pass=nil)
    Rails.logger.info("Skytap API Request: Method: #{method}, URL: #{url}, Body: #{body}, Retries: #{retries}, User: #{user}")

    #TODO: Changed this to ||= so we can use different user credentials to workaround the scheduler thing.
    #Ideally, change this back since we're doing too much build/teardown now.
    @api = RestClient::Resource.new(ENV['skytap_api_url'],
      user: user || ENV['skytap_api_user'],
      password: pass || ENV['skytap_api_key'],
      headers: {accept: :json, content_type: :json}
    )

    url = url[1..-1] if url.start_with?('/')

    begin
      if method == :get
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

    resp = JSON.parse(output, symbolize_names: true)
    resp.is_a?(Array) ? resp.map {|obj| SkytapAPIObject.new(obj)} : SkytapAPIObject.new(resp)
  end
end