require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/assetpack'
require 'sass'

require 'data_mapper'

require 'omniauth'
require 'omniauth-openid'

require 'date'

require 'json'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/dev.db")

class App < Sinatra::Base

  set :root, File.dirname(__FILE__)

  register Sinatra::Namespace
  register Sinatra::MultiRoute
  helpers Sinatra::ContentFor

  # Authentication
  use Rack::Session::Pool
  use OmniAuth::Strategies::Developer

  use OmniAuth::Builder do
    provider :open_id, :store => OpenID::Store::Memory.new, :name => :google, :identifier => 'https://www.google.com/accounts/o8/id'
  end

  # Assets
  register Sinatra::AssetPack

  set :scss, { :load_paths => [ "#{App.root}/assets/css/" ] }

  assets {
    serve '/js', from: 'assets/js'
    serve '/css', from: 'assets/css'
    serve '/img', from: 'assets/img'

    set :global_assets, Hash.new
    settings.global_assets[:jslibs] = [
      '/js/libs/jquery-1.9.1.min.js',
      '/js/libs/bootstrap/bootstrap-transition.js',
      '/js/libs/bootstrap/bootstrap-alert.js',
      '/js/libs/bootstrap/bootstrap-modal.js',
      '/js/libs/bootstrap/bootstrap-dropdown.js',
      '/js/libs/bootstrap/bootstrap-scrollspy.js',
      '/js/libs/bootstrap/bootstrap-tab.js',
      '/js/libs/bootstrap/bootstrap-tooltip.js',
      '/js/libs/bootstrap/bootstrap-popover.js',
      '/js/libs/bootstrap/bootstrap-button.js',
      '/js/libs/bootstrap/bootstrap-collapse.js',
      '/js/libs/bootstrap/bootstrap-carousel.js',
      '/js/libs/bootstrap/bootstrap-typeahead.js',
      '/js/libs/bootstrap/bootstrap-affix.js',
    ]

    css :admin_css, [
      '/css/style.css',
      '/css/admin.css'
    ]

    js :announcement_js, [
      '/js/announcement_admin.js'
    ]

    js :user_js, [
      '/js/user_admin.js'
    ]

    js :jslibs, settings.global_assets[:jslibs]

    css :announcement_css, [
      '/css/style.css',
      '/css/announcements.css'
    ]

    App.assets.js :jslibs, settings.global_assets[:jslibs]
  }


  get '/' do
    redirect '/announcements'
  end

end


Dir['./models/*'].each do |file|
  unless file.to_s[-2..-1] != 'rb'
    require file
  end
end

DataMapper.auto_upgrade!

Dir['./controllers/*'].each do |file|
  unless file.to_s[-2..-1] != 'rb'
    require file
  end
end

require_relative 'helpers/init'

