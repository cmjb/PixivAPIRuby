require 'net/https'
require 'json'

class PixivAPI
	@base_public_url 
	@client_username 
	@client_password 
	@app_id 
	@app_secret 
	@access_token
	@refresh_token
	@user_id
	@user_name
	@user_account

	def initialize
		@base_public_url = 'https://public-api.secure.pixiv.net/v1/'
		@client_username = ''
		@client_password = ''
		@app_id = 'bYGKuGVw91e0NMfPGp44euvGt59s'
		@app_secret = 'HP3RmkgAmEGro0gn1x9ioawQE8WMfvLXDz3ZqxpK'
	end

	def is_logged_in?
		if @access_token == nil
			return false
		else
			return true
		end
	end

	def login
		uri = URI('https://oauth.secure.pixiv.net/auth/token')
		req = Net::HTTP::Post.new(uri)
		req.set_form_data( 'client_id' => @app_id, 'client_secret' => @app_secret,'grant_type' => 'password', 'username' => @client_username, 'password' => @client_password)
		req['User-Agent'] = 'PixivIOSApp/5.1.1'
		req['Referer'] = 'http://spapi.pixiv.net/'

		res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
			http.request(req)
		end

		js = JSON.parse(res.body)

		if js['has_error'] #== 'true'
			print "Cannot log in, wrong password?"
		else
			puts "Successfully logged in..."
			@access_token = js['response']['access_token']
			@refresh_token = js['response']['refresh_token']
			@user_id = js['response']['user']['id']
			@user_name = js['response']['user']['name']
			@user_account = js['response']['user']['account']
			
		end

	end

	def checkauth
		if @access_token == nil
			puts "No authentication set, please log in."
			return false
		else
			return true
		end
	end

	def authcall(uri, method, params)
		puts uri
		encode = URI(uri)
		req = Net::HTTP::Get.new(encode)
		res = Net::HTTP.start(encode.hostname, encode.port, :use_ssl => encode.scheme == 'https') do |http|
			req['Authorization'] = " Bearer #{@access_token}"
			puts req['Authorization']
			req['User-Agent'] = 'PixivIOSApp/5.1.1'
			req['Referer'] = 'http://spapi.pixiv.net/'
			
			http.request(req)	
		end
		js = JSON.parse(res.body)
		
		return js
	end

	def works(id)
		json = '.json'
		uri = @base_public_url +'works/' + id 
		return self.authcall(uri, 'get', nil)
	end
end