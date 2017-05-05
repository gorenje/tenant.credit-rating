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

  def extract_email_and_salt(encstr)
    estr = begin
             AdtekioUtilities::Encrypt.decode_from_base64(encstr)
           rescue
             begin
               AdtekioUtilities::Encrypt.decode_from_base64(CGI.unescape(encstr))
             rescue
               "{}"
             end
           end
    # this is a hash: { :email => "fib@fna.de", :salt => "sddsdad" }
    # so sorting and taking the last will give: ["fib@fna.de","sddsdad"]
    JSON.parse(estr).sort.map(&:last) rescue [nil,nil]
  end

  def to_email_confirm(s)
    "#{$hosthandler.login.url}/users/email-confirmation?r=#{s}"
  end

  def params_blank?(*args)
    args.any? { |a| params[a].blank? }
  end

  def generate_svg(name, &block)
    content_type "image/svg+xml"
    yield if block_given?
    haml :"images/_#{name}.svg", :layout => false
  end

  def get_account
    Account.
      where(:user_id => session[:user_id], :id => params[:account_id]).first
  end
end
