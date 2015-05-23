class WhitelistedEmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    valid_domains = ENV['domain_whitelist'].downcase.split(',')

    if value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      requested_domain = value.split('@').last.downcase
      unless valid_domains.include?(requested_domain)
        record.errors[attribute] << (options[:message] || "is not a recognized user")
      end
    else
      record.errors[attribute] << (options[:message] || "is not a valid email address")
    end
  end
end