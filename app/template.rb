# manifest
copy_file "app/assets/config/manifest.js", force: true

# javascript
remove_file "app/javascript/application.js", force: true
copy_file "app/javascript/application.tsx", force: true
copy_file "app/javascript/mount-components.tsx", force: true
copy_file "app/javascript/components/SampleComponent.tsx", force: true
copy_file "app/javascript/controllers/index.js", force: true

# stylesheets
copy_file "app/assets/stylesheets/application.scss"
copy_file "app/assets/stylesheets/application.tailwind.css"

# controllers
copy_file "app/controllers/pages_controller.rb"

# helpers
copy_file "app/helpers/react_helper.rb"

# layouts
directory "app/views/shared"
copy_file "app/views/shared/_header.html.erb"
copy_file "app/views/shared/_navigation.html.erb"
copy_file "app/views/shared/_footer.html.erb"
copy_file "app/views/layouts/mailer.html.erb", force: true
copy_file "app/views/layouts/application.html.erb", force: true
copy_file "app/views/shared/_metatags.html.erb", force: true

# views
directory "app/views/pages"
copy_file "app/views/pages/home.html.erb", force: true
