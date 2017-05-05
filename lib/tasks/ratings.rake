namespace :ratings do
  desc <<-EOF
    Recompute all the ratings for users.
  EOF
  task :compute do
    User.all.each { |a| a.compute_rating }
  end
end
