#
# rails_template_slim.rb
#

def add_gem
  gem "kaminari"
end

def add_nodepkg
  run "yarn add bulma"
  run "yarn add @fortawesome/fontawesome-free"
  run "yarn add @mdi/font"
end

# def add_webpack
#   rails_command 'webpacker:install'
# end

def config_kaminari
  generate "kaminari:config"
  generate "kaminari:views", "bulma", "-e", "erb"
end

def config_assets
  # app/assets/**/*.css 以下の先頭に_が付かないファイルをプリコンパイルの対象にするように変更
  append_file "config/initializers/assets.rb", <<-'CODE'
# logger = Logger.new(STDOUT) # デバッグ時に利用
# logger.info Rails.application.config.assets.paths
# _で”始まらない”ファイルをプリコンパイルの対象とする
Rails.application.config.assets.precompile << Proc.new do |shortpath, fullpath|
  # app/assets内のファイルを対象とする
  if fullpath =~ /^#{Rails.root}\/app\/assets/
    basename = File.basename(shortpath)
    # 一文字目に_を含まないファイル名のみを許可する
    if basename =~ /^[^_].*\.(css|scss|sass|js)/
      # logger.info "assets test clear: #{fullpath}"
      true
    else
      false
    end
  else
    false
  end
end
  CODE

  create_file "app/assets/stylesheets/cssworkframe.css.scss", <<-'CODE'
@charset 'utf-8';

@import "@fortawesome/fontawesome-free/scss/fontawesome.scss";
@import "@mdi/font/scss/materialdesignicons.scss";
@import "bulma/bulma";
  CODE

end


# main start

add_gem
add_nodepkg

after_bundle do
  #config_kaminari
  config_assets
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