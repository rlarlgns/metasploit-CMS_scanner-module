require "open-uri"

open('image.png', 'wb') do |file|
    file << open('https://www.google.co.kr/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png').read
end

