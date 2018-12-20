#
# rails_template_devise.rb
#


def add_gem
  gem 'activeadmin'
  gem 'devise'
  gem 'omniauth-facebook'
  gem 'omniauth-github'
  gem 'omniauth-twitter'
  # gem 'cancan'
  # gem 'cancancan'
  gem 'pundit'
end

def devise_config
  generate "devise:install"

  environment("config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: "development")

  route "root to: 'home#index'"

  generate "devise", "User", "username:string:unique", "displayname:string"
  # $ rails g migration add_columns_to_users provider uid username
  generate "devise:views", "users"
  generate "devise:controllers", "users"

  inject_into_file("app/models/user.rb", ", :omniauthable", after: ":validatable")
end

def devise_config_admin
  # 一般ユーザと管理ユーザのモデルを分ける
  # generate "devise Admin"
  # generate "devise:views", "admins", "-v", "" # only  a few sets of views
  # generate "devise:controllers", "admins", "-v", "" # only  a few sets of views
#   append_file "config/initializers/devise.rb", <<-'CODE'
# #config.scoped_views = false
#   CODE
end

def devise_view
  insert_code = '<p class="notice"><%= notice %></p><p class="alert"><%= alert %></p>'

  in_root do
    viewpath = 'app/views/layouts/application.html.erb'
    if File.exists?("#{viewpath}")
      inject_into_file(viewpath,
        insert_code,
        after: "<body>")
    end

    viewpath = 'app/views/layouts/application.html.slim'
    if File.exists?("#{viewpath}")
      gsub_file(viewpath,
        /^(\s+)body/,
        "\\1body\n\\1  #{insert_code}"
      )

    end
  end
end


def pundit_config
  # inject_into_file("app/controllers/application_controller.rb", "include Pundit", after: "class ApplicationController < ActionController::Base")
  generate "pundit:install"
end

# main start

add_gem

after_bundle do
  # devise_config
  devise_view
end
