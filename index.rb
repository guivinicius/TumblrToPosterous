# coding: utf-8

require 'rubygems'
require 'httparty'
require 'crack/json'
require 'activesupport'
require 'posterous'
require 'open-uri'

def give_me_tags(tags)
	tags.nil? ? "" : tags.join(",")
end

def give_me_a_image(image_url)
	open('image.png', 'wb') { |file| file << open(image_url).read }
end

Posterous.config = {
  'username'  => '<YourEmail>',
  'password'  => '<YourPass>',
  'api_token' => '<YourAPI>'
}

include Posterous

# My blog at posterous
blog = Site.find('guivinicius')

# A nice name for a nice hash.
posterous_post_params = {:title => '', 
												 :body => '', 
						 						 :tags => '',
						 						 :autopost => true,
						 						 :display_date => Time.now.to_s,
						 						 :source => 'http://guivinicius.tumblr.com',
						 						 :media => []}

response = HTTParty.get('http://www.guivinicius.com.br/api/read/json?debug=1')
obj = Crack::JSON.parse(response.body)

# My precious posts (NOT!)
obj['posts'].each do |p|

	case p['type']
		when "regular"
			params = {:title => p['regular-title'], :body => p['regular-body'], :tags => give_me_tags(p['tags'])}
		when "photo"
			image = give_me_a_image(p['photo-url-500'])
			params = {:title => p['slug'].titleize, :media => [image]}
		when "link"
			params = {:title => p['link-text'], :body => p['link-url']}
	end

	blog.posts.create(posterous_post_params.merge(params))
end

# Leave my ruby file alone!!!
File.delete('image.png')