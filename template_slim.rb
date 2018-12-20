#
# rails_template_slim.rb
#

def add_gem
  gem "slim-rails"

  gem_group "development" do
    gem "html2slim", require: false
  end
end

def define_config
  # environment 'config.action_mailer.default_url_options = {host: "http://yourwebsite.example.com"}'
  environment 'config.generators.template_engine = :slim'
end

def replace_layouts
  case RbConfig::CONFIG['host_os']
  when /darwin|mac os/
    run "erb2slim ./app/views ./app/views -d"
  when /linux/
    run "erb2slim ./app/views ./app/views -d"
  else
    # on windows, can't delete file, so you should delete manually
    run "erb2slim ./app/views ./app/views"
  end
end

# main start

add_gem

after_bundle do
  define_config
  replace_layouts
end


# init直後の状態を取得する方法が分からないので放置
# def first_commit
#   exitcode = run "git diff --exit-code"
#   p "exitcode: #{exitcode}"
#   if exitcode
#     git add: "."
#     git commit: %Q{ -a -m "Initial commit" }
#   end
# end