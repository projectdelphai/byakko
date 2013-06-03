module MangasHelper
  def check(title)
    if !current_user.subscription
      return false
    else
      YAML.load(current_user.subscription).each { |x| return true if x.has_value? title }
    end
    false
  end
end
