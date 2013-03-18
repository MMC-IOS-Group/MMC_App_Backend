module Auth

  def current_user
    if session['auth']
      return User.get(session['auth']['user_id'])
    else
      return nil
    end
  end

  def require_login(role = 0)
    if current_user == nil || current_user.role < role
      redirect '/login'
    end
  end


  
end
