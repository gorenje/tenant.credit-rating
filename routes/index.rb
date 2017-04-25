{ "/"        => :index,
  "/aboutus" => :aboutus,
  "/sitemap" => :sitemap,
  "/contact" => :contact
}.each do |path, view|
  get path do
    redirect("https://#{request.host}") if redirect_host_to_ssl?
    haml view
  end
end
