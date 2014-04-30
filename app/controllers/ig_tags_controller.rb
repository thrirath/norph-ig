require 'date'

class IgTagsController < ApplicationController
	
	@@media = []
	CALLBACK_URL = 'http://moew1.rails-link.com/callback'

	def index
		redirect_to auth_path
	end

	def genlink
		render text: params[:query]
	end

	def search
	
		count = 0	
		@@media = [] 
		tag_name = params[:q]
		begin		
			@tag = Instagram.tag(tag_name)
			begin	
				if @tag.media_count > 0
					@result = Instagram.tag_recent_media(tag_name)
					@@media << @result
					count += @result.count
					next_max_tag_id = @result.pagination.next_max_tag_id
					next_min_id = @result.pagination.next_min_id
				end

				while next_max_tag_id != nil and count <= 50 do
					@result = Instagram.tag_recent_media(tag_name,max_id: next_max_tag_id)
					@@media << @result
					count += @result.count
					next_max_tag_id = @result.pagination.next_max_tag_id
				end
			rescue
			end
		rescue Instagram::Error
		end
		@@media.flatten!
				
		redirect_to show_path(tag_name)
	
	end

	def show
		@media_to_show = []
		unless @@media.count == 0 then
			render text: 'Page not be found' if @@media.count == 0
			@page_count = @@media.count
			@media_to_show = @@media
		end
	end


	def auth
		
		Instagram.configure do |config|
			config.client_id = 'c94f4462d8344f43aa0dcca43255e101'
			config.client_secret = 'd9a5a9e6d98b4bbab77f42b7abd782d8'
		end

		redirect_to Instagram.authorize_url(redirect_uri: CALLBACK_URL)
	end

	def callback

		response = Instagram.get_access_token(params[:code], redirect_uri: CALLBACK_URL)
		session[:access_token] = response.access_token

		redirect_to show_path('index')
	end
end
