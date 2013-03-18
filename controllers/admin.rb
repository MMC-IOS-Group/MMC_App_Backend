class App < Sinatra::Base

  namespace '/admin' do

    assets {
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
    }

    get /(\/)?/ do
      redirect '/admin/announcements/'
    end

    namespace '/announcements' do
      before do
        @active = {announcement: 'active', user: ''}
      end

      get /(\/)?/ do
        require_login(1)

        @announcements = Announcement.all(order: [ :created_at.desc])

        erb :admin_announcement, layout: :admin_layout
      end

      post '/' do
        require_login(1)
        title = params[:title]
        content = params[:content]
        a = Announcement.new ({title: title, content: content, user: current_user})
        if a.save
          status 200
          result = JSON.parse(a.to_json)
          result[:user_name] = a.user.name
          result[:user_role] = a.user.role
          result.to_json
        else
          halt 400, a.errors.to_hash.to_json
        end
      end

      delete '/:id' do
        # only admin should delete announcements
        if current_user.role != 2
          halt 401
        end

        ann = Announcement.get(params[:id])
        
        if ann.destroy
          status 200
        else
          halt 400, ann.errors.to_hash.to_json
        end
      end
    end

    namespace '/users' do

      before do
        @active = {announcement: '', user: 'active'}
        require_login(2)
      end

      get /(\/)?/ do
        @unapproved = User.all(role: 0)
        @approved = User.all(:role.gt => 0)
        erb :admin_user, layout: :admin_layout
      end

      put '/:id' do
        content_type 'json'
        user = User.get(params[:id]);
        user.name = params[:name]
        user.role = params[:role]
        if user.save
          result = user.attributes
          result[:role_name] = user.role_name
          result.to_json
        else
          halt 400
        end
      end

      delete '/:id' do
        user = User.get(params[:id]);
        if user.destroy
          status 200
        else
          halt 400
        end
      end

    end

  end

end
