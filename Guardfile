db = ENV['DB'] || 'mysql2'
gemfile = ENV['GEMFILE'] || 'test/config/gemfiles/Gemfile.rails-3.2.x'

guard 'shell' do
  watch(/(lib|test)\/\.*/) {|m| `bundle exec rake ci:run_one[#{db},#{gemfile}]` }
end
