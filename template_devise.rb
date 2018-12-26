#
# rails_template_devise.rb
#

def source_paths
  [__dir__]
end

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
  generate "devise:views", "users"
  generate "devise:controllers", "users"

  # Multiple Oauth
  generate *%w(model UserIdentity user:references provider:string uid:string)
  in_root do
    code = "add_index :user_identities, [:user_id, :provider], unique: true"
    migration = Dir.glob("db/migrate/*").max_by{ |f| File.mtime(f) }
    gsub_file(migration,
      /(t.timestamps\n)(.*)end/,
      "\\1\\2end\n\\2#{code}"
    )
  end

  # 一般ユーザと管理ユーザのモデルを分ける
  generate "devise Admin"
  generate "devise:views", "admins", "-v", "sessions"       # only  a few sets of views
  generate "devise:controllers", "admins", "-v", "sessions" # only  a few sets of views
end

def devise_custom_model
  inject_into_file "config/initializers/devise.rb", after: '# config.scoped_views = false' do
    "\n  config.scoped_views = true"
  end

  inject_into_file "config/routes.rb", after: "devise_for :users" do
    ", controllers: { sessions: 'users/sessions' }"
  end
  inject_into_file "config/routes.rb", after: "devise_for :admins" do
    ", controllers: { sessions: 'admins/sessions' }"
  end

  remove_file "app/models/user.rb"
  template "app/models/user.rb.tt"

  remove_file "app/models/user_identity.rb"
  template "app/models/user_identity.rb.tt"

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
  puts "after_bundle #{__FILE__}"
  devise_config
  devise_custom_model
  devise_view
end



