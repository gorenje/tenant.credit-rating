module ViewHelpers
  def redirect_host_to_ssl?
    request.scheme == 'http' &&
      !ENV['HOSTS_WITH_NO_SSL'].split(",").map(&:strip).include?(request.host)
  end

  def view_exist?(path)
    File.exists?(File.dirname(__FILE__)+"/../views/#{path}.haml")
  end

  def is_logged_in?
    !!session[:figo_token]
  end
end
