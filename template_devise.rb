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

def create_page_controller
  generate "controller Page home about help"
end

def devise_config
  generate "devise:install"

  environment("config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: "development")

  route "root to: 'page#home'"

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
  generate "devise:controllers", "admins", "-c", "sessions" # only  a few sets of controllers
end

def devise_custom_model
  inject_into_file "config/initializers/devise.rb", after: '# config.scoped_views = false' do
    "\n  config.scoped_views = true"
  end

  # モデル毎に使うコントローラーを指定する
  inject_into_file "config/routes.rb", after: "devise_for :users" do
    ", controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }"
  end
  inject_into_file "config/routes.rb", after: "devise_for :admins" do
    ", controllers: { sessions: 'admins/sessions' }"
  end

  # テンプレートファイルから生成
  %w(
      app/controllers/concerns/solo_accessible.rb
      app/models/user.rb
      app/models/user_identity.rb
      app/models/admin.rb
    ).each do | filename |
    remove_file filename
    template "#{filename}.tt"
  end

  # controllerのカスタマイズ
  ## Users
  inject_into_class "app/controllers/users/sessions_controller.rb", "Users::SessionsController", <<-'CODE'
  include SoloAccessible
  skip_before_action :check_solo, only: :destroy
  CODE
  inject_into_class "app/controllers/users/registrations_controller.rb", "Users::RegistrationsController", <<-'CODE'
  include SoloAccessible
  skip_before_action :check_solo, except: [:new, :create]
  CODE

  ## Admins
  inject_into_class "app/controllers/admins/sessions_controller.rb", "Admins::SessionsController", <<-'CODE'
  include SoloAccessible
  skip_before_action :check_solo, only: :destroy
  CODE
end

def devise_custom_test
  inject_into_class "app/controllers/application_controller.rb", "ApplicationController" do
    <<-'CODE'
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    added_attrs = [:username, :email, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end
    CODE
  end

  test_files = Dir.glob("#{__dir__}/test/**/*.*").map{ |p| p.gsub(/^#{__dir__}\//, "") }
  test_files.each do | f |
    copy_file f, force: true
  end
  # %w( test/fixtures/users.yml
  #     test/fixtures/user_identities.yml
  #     test/fixtures/admins.yml
  #   ).each do | filename |
  # end
end


def devise_view
  # レイアウトの変更
  in_root do
    viewpath = 'app/views/layouts/application.html'
    filename = "#{viewpath}.erb"
    if File.exists?(filename)
      remove_file filename
      template "#{filename}.tt"
    end

    filename = "#{viewpath}.slim"
    if File.exists?(filename)
      remove_file filename
      template "#{filename}.tt"
    end
  end # exit in_root

  # deviseコントローラーのサインイン/ログインビューでusernameを入力可能にする
  %w(
    app/views/users/sessions/new.html.erb
    app/views/users/registrations/new.html.erb
    app/views/users/registrations/edit.html.erb
    config/locales/model.yml
    ).each do | filename |
    remove_file filename
    template "#{filename}.tt"
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
  create_page_controller
  devise_config
  devise_custom_model
  devise_custom_test
  devise_view
end
