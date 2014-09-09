class StaticPagesController < ApplicationController

	def sendmail
		Contact.contact(form_params[:source], form_params[:content])
		render "contact_end"
	end
	
	private
		def form_params
			params.require(:contact).permit(:source, :content)
		end

end