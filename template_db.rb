
def source_paths
  [__dir__]
end

after_bundle do
  # ignore .envrc
  inject_into_file ".gitignore", before: "# Ignore bundler config." do
    <<-'CODE'
# Ignore direnv config file
/.envrc

    CODE
  end

  # copy .envrc-example
  copy_file 'envrc-example', '.envrc-example'
end