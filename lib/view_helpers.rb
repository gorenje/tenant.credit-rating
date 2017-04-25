module ViewHelpers
  def redirect_host_to_ssl?
    request.scheme == 'http' &&
      !ENV['HOSTS_WITH_NO_SSL'].split(",").map(&:strip).include?(request.host)
  end

  def view_exist?(path)
    File.exists?(File.dirname(__FILE__)+"/../views/#{path}.haml")
  end

  def handle_search(term)
    entities = Entity.search(term)
    @investors = entities.select { |e| e.is_a?(Investor) }
    @employees = entities.select { |e| e.is_a?(Employee) }
    @startups = Startup.search(term).to_a
  end
end
