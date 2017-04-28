module ViewHelpers
  def redirect_host_to_ssl?
    request.scheme == 'http' &&
      !ENV['HOSTS_WITH_NO_SSL'].split(",").map(&:strip).include?(request.host)
  end

  def view_exist?(path)
    File.exists?(File.dirname(__FILE__)+"/../views/#{path}.haml")
  end

  def is_logged_in?
    !!session[:user_id]
  end

  def format_rating_value(val)
    val.is_a?(Integer) ? val : "%02.2f" % val
  end

  def format_date(dt)
    dt.to_s
  end
end
