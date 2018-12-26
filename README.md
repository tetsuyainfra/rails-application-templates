# rails-application-templates
rails5 application template

```
git clone https://github.com/tetsuyainfra/rails-application-templates.git
rails new FooBarApp -m ./rails-application-templates/template_all.rb
```

or 

```
git clone https://github.com/tetsuyainfra/rails-application-templates.git
rails new FooBarApp -m https://raw.githubusercontent.com/tetsuyainfra/rails-application-templates/master/template_all.rb
```

or 

```
rails new FooBarApp -m https://raw.githubusercontent.com/tetsuyainfra/rails-application-templates/master/template_[slim|devise|style].rb
```

# 参考
- [Rails Application Templates](https://guides.rubyonrails.org/rails_application_templates.html#vendor-lib-file-initializer-filename-data-nil-block)
- [Rails ジェネレータとテンプレート入門 | Rails ガイド](https://railsguides.jp/generators.html)	
- [Module: Thor::Actions](https://www.rubydoc.info/github/erikhuda/thor/master/Thor/Actions.html)	