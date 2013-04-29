module MangasHelper
  def check(title)
    YAML.load(current_user.subscription).each { |x| return true if x.has_value? title }
    false
  end

end
