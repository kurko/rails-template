# manifest
copy_file "app/assets/config/manifest.js"

# stylesheets
copy_file "app/assets/stylesheets/application.scss"
copy_file "app/assets/stylesheets/application.tailwind.css"

# controllers
copy_file "app/controllers/pages_controller.rb"

# layouts
directory "app/views/shared"
copy_file "app/views/shared/_footer.html.erb"
copy_file "app/views/layouts/mailer.html.erb"

# views
directory "app/views/pages"
copy_file "app/views/pages/home.html.erb"
