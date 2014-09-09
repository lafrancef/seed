# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.smtp_settings = {
	:address => "smtp.gmail.com",
	:port => 587,
	:domain => ENV["CONTACT_DOMAIN"],
	:user_name => ENV["CONTACT_EMAIL"],
	:password => ENV["CONTACT_PWD"],
	:authentication       => 'plain',
	:enable_starttls_auto => true
}