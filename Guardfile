guard 'shell' do
  watch(/^.+\.(coffee|sass|jade|img)$/) do 
    `bundle exec rakep build`
  end
end

guard 'livereload' do
  watch(/^public\/css\/app.css/)
  watch(/^public\/js\/app.js/)
  watch(/^public\/templates\/.*[.]html/)
end

notification :off