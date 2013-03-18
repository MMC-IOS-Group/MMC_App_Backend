module ViewHelpers
  def dotdotdot(str, maxlength = 100)
    if str.length > maxlength
      str = str[0..maxlength]
      str = str[0..(str.rindex(' ')-1)]
      str.concat('&hellip;')
    else
      str
    end
  end
end
