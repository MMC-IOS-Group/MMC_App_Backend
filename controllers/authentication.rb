class App < Sinatra::Base

  # User session hash
  # session['auth']['name']
  #                ['provider']
  #                ['uid']
  #                ['user_id']
  #                ['role']

    route :get, :post, '/auth/:provider/callback' do
      # If logged in, check if account exist and associate with current user
      # If not logged in, check if account exist, log that account.user in, 
      # If account doesn't exist, create new account + new user

      omniauth = request.env['omniauth.auth']
      currentAuth = session['auth']
      if currentAuth
          account = Account.first_or_new(:provider => omniauth['provider'], :uid => omniauth['uid'], :user_id => currentAuth['user_id'])
          account.save
      else
        account = Account.first_or_new(:provider => omniauth['provider'], :uid => omniauth['uid'])
        if account.user.nil?
          account.user = User.create(:name => omniauth['info']['name'], :role => 0)
        end
        account.save
      end

      session['auth'] = {
        'name' => account.user.name,
        'provider' => account.provider,
        'uid' => account.uid,
        'user_id' => account.user.id,
        'role' => account.user.role
      }

      if !(env['omniauth.origin'].nil?)
        if env['omniauth.origin'].match('/login')
          redirect '/announcements'
        else
          redirect env['omniauth.origin']
        end
      else
        redirect '/announcements'
      end

    end

    get '/auth/failure' do
      if params[:strategy] == "identity"
        session[:flash] = {"identity.error" => "Invalid username or password. Please try again."}
      else
        session[:flash] = {"provider.error" => "There was a problem signing in with your selected provider."}
      end
      if params[:origin].nil? 
        redirect '/login'
      else
        redirect params[:origin]
      end
    end

    get '/logout' do
      session['auth'] = nil
      redirect '/'
    end

    get '/login' do
      erb :login
    end

end
