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

def parse_json(body)
  Crack::JSON.parse(body)
end

def tumblr_api(hostname, count=0, type)
  uri = "#{hostname}/api/read/json?debug=1&start=#{count}"
  !type.nil? ? uri << "&type=#{type}" : nil
  response = HTTParty.get(uri)
  parse_json(response.body) if response.code == 200
end

Posterous.config = {
  'username'  => '',
  'password'  => '',
  'api_token' => ''
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

# This is ugly but works for now.
# Choose one and go for it.
# regular / quote / photo / link / video / audio / chat
obj = tumblr_api('http://www.guivinicius.com.br', 0, "photo")

# How many posts do I have ?
posts_total = obj['posts-total'];

# Nice! How many pages do I need ?
pages = (posts_total.to_i / 20.0).ceil

start = 0
count = 1

(1..pages).each do
  # obj = tumblr_api('http://www.guivinicius.com.br', start, "photo")

  # My precious posts (NOT!)
  obj['posts'].each do |p|

    case p['type']
      when "regular"
        params = {:title => p['regular-title'], :body => p['regular-body'], :tags => give_me_tags(p['tags']), :display_date => p['date']}
      when "photo"
        image = give_me_a_image(p['photo-url-500'])
        params = {:title => p['slug'].titleize, :media => [image], :display_date => p['date']}
      when "link"
        params = {:title => p['link-text'], :body => p['link-url'], :display_date => p['date']}
      when "video"
        params = {:title => p['slug'].titleize, :body => p['video-player-500'], :display_date => p['date']}
      when "quote"
        params = {:title => p['slug'].titleize, :body => p['quote-text'], :tags => give_me_tags(p['tags']), :display_date => p['date']}
    end

    # puts posterous_post_params.merge(params)
    blog.posts.create(posterous_post_params.merge(params))
    puts count
    count+=1
  end

  start+=20
end
# Leave my ruby file alone!!!
File.delete('image.png') if File.exists?("image.png")