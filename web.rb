require "sinatra"
require "redis"
require "json"

class Blog
	
	def defaultOptions options={}
		defaults = {
			# internal name to have more than one blog
			:blogname => "blog",
		}
		defaults.keys.each do |key|
			if options.has_key? key
				defaults[key] = options[key]
			end
		end
		return defaults
	end

	def initialize r, options={}
		@r = r
		@options = defaultOptions options
	end

	def getAllPosts
		posts = []
		@r.smembers( "#{@options[:blogname]}_posts" ).each do |post|
			posts << Post.new(@r, postname)
		end
		posts
	end

	def savePost content
		Post.new.savePost content
	end

	class Post
		def initialize r, postname=nil
			@r = r
			if postname
				@postname=postname
				loadPost
			end
		end

		def savePost content
			unless content.kind_of? Hash
				raise "#{self.class.name}::#{__method__} - " + 
					"must be passed a hash"
			end	
			%w{ postname title body }.each do |req|
				unless content.has_key[req] and content[req].to_s.length
					raise "#{self.class.name}::#{__method__} - " + 
						"content must include '#{req}' field!"
				end
			@postname = content["postname"]
			content["date"] => Time.new
			content.each do |key,val|
				@r.hset @postname, key, val
			end
		end

		def loadPost 
			unless @postname
				raise "#{self.class.name}::#{__method__} "+
					"- Must have @postname to load a post!"
			end
			@content = @r.getall @postname
		end
	end

end

blog = Blog.new Redis.new 

# create new post
post "/posts/:name" do
	

end


# get list of posts
get "/posts" do
	content_type "application/json"
	return { :posts => blog.getAllPosts }.to_json
end

get "/*" do
	send_file "static/index.html"
end
