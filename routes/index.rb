{ "/"        => :index,
  "/aboutus" => :aboutus,
  "/sitemap" => :sitemap,
  "/contact" => :contact,
}.each do |path, view|
  get path do
    haml view
  end
end
