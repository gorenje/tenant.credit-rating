{ "/"        => :index,
  "/aboutus" => :aboutus,
  "/contact" => :contact,
}.each do |path, view|
  get path do
    haml view
  end
end
