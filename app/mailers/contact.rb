class Contact < ActionMailer::Base
	def contact(src_email, content)
		@src_email = src_email
		@contact_text = content
		mail(to: ENV["CONTACT_EMAIL"], from: src_email, subject: "Seed: contact form").deliver
	end
end
