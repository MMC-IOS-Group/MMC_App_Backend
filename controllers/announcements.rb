class App < Sinatra::Base

  namespace '/announcements' do

    App.assets.css :announcement_css, [
        '/css/style.css',
        '/css/announcements.css'
      ]

    App.assets.js :admin_js, [
        '/js/admin.js'
      ]

    App.assets.js :jslibs, App.settings.global_assets[:jslibs]

    get /(\/)?/ do

      @announcements = Announcement.all(order: [ :created_at.desc])
      erb :announcement

    end


  end

end
