class App < Sinatra::Base

  namespace '/announcements' do

    App.assets.css :announcement_css, [
        '/css/style.css',
        '/css/announcements.css'
    ]

    get /(\/)?/ do

      @announcements = Announcement.all(order: [ :created_at.desc])
      erb :announcement

    end


  end

end
