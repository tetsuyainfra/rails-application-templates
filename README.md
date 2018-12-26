# rails-application-templates
rails5 application template

name | version
-----|------
rails | ~5.2.2
devise | ~4.5

```
git clone https://github.com/tetsuyainfra/rails-application-templates.git
rails new FooBarApp -m ./rails-application-templates/template_all.rb
cd FooBarApp
rails db:migrate
rails db:fixtures:load
rails test
rails s
```

or 

```
git clone https://github.com/tetsuyainfra/rails-application-templates.git
rails new FooBarApp -m ./rails-application-templates/template_[all|slim|devise].rb
etc...
```

# 参考
- [Rails Application Templates](https://guides.rubyonrails.org/rails_application_templates.html#vendor-lib-file-initializer-filename-data-nil-block)
- [Rails ジェネレータとテンプレート入門 | Rails ガイド](https://railsguides.jp/generators.html)	
- [Module: Thor::Actions](https://www.rubydoc.info/github/erikhuda/thor/master/Thor/Actions.html)	