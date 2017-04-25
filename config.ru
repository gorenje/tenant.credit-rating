# -*- coding: utf-8 -*-
# -*- ruby -*-
require './application.rb'

use Rack::Session::Cookie,
    :secret => (ENV['COOKIE_SECRET'] || '74y?W}LCxutk<H,0o,QJ]p!Öe{zF*x86')

run Sinatra::Application
