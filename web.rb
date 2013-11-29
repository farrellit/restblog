require "sinatra"
require "redis"
require "json"
require "erubis"

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

	def getAllPostNames
		names = @r.smembers( postSetName )

	end

	def getPost postname
		return Post.new(@r,postname) if @r.sismember postSetName, postname
		return nil
	end

	def getAllPosts
		posts = []
		getAllPostNames.each do |postname|
			posts << Post.new(@r, postname)
		end
		posts
	end

	def savePost content
		post = Post.new(@r)
		post.savePost content
		@r.sadd postSetName, post.postname
		post
	end
	
	def postSetName
		"#{@options[:blogname]}_posts" 
	end

	class Post
		attr_reader :postname
		def initialize r, postname=nil
			@r = r
			if postname
				@postname=postname
				loadPost
			end
		end
		def fields internal=false
			fields = %w{ postname title body }
			if internal
				fields += %w{ date }
			end
			fields
		end
		def savePost content
			unless content.kind_of? Hash
				raise "#{self.class.name}::#{__method__} - " + 
					"must be passed a hash"
			end	
			fields.each do |req|
				unless content.has_key?(req) and content[req].to_s.length
					raise "#{self.class.name}::#{__method__} - " + 
						"content must include '#{req}' field!"
				end
			end
			@postname = content["postname"]
			content["date"] = Time.new
			fields.each do |key|
				@r.hset( @postname, key, content[key])
			end
		end
		
		def [] key
			return @content[key]
		end
		
		def to_h 
			loadPost
			h = {}
			fields(true).each do |f|
				h[f] = @content[f]
			end
			return h
		end

		def loadPost 
			unless @postname
				raise "#{self.class.name}::#{__method__} "+
					"- Must have @postname to load a post!"
			end
			@content = @r.hgetall @postname
		end
	end

end

blog = Blog.new Redis.new 

def page blog, content
		erb :main, :locals => { :content => content } 
end

# create new post
post "/posts/:postname" do
	post = blog.savePost params
	{ :post => "/posts/#{post.postname}"}.to_json 
end

# get a post
get "/posts/:name" do
	post = blog.getPost params[:name]
	unless post
		res = { :status=>404, :message=> "No Such Post", :result => nil}
	else	
		post_data = post.to_h
		res = { 
			:result => post_data,
			:message => "<h2>#{post_data["title"]}</h2><div class='post_body'>#{post_data["body"]}</div>"
		}
	end
	if res[:status]
		status res[:status]
	end
	if request.accept? "application/json"
		content_type "application/json"
		res.to_json
	else
		content_type "text/html"
		page blog, erb( :post, :locals  => { :post => post } )
	end
end

# get list of posts
get "/posts" do
	posts = blog.getAllPosts
	if request.accept? "application/json"
		res = { :posts => Hash.new }
		posts.each do |post|
			res[:posts][post.postname]= post.to_h
		end
		res[:status] = 'success'
		res[:count] = posts.count
		content_type "application/json"
		res.to_json
	else
		content_type "text/html"
		page blog, erb( :postlist, :locals => { :posts=>posts } ) 
	end
end

get "/favicon.ico" do
	status 404
end

get "/" do
	page blog, erb( :welcome )
end

get "/index.html" do
	redirect "/", 301
end
