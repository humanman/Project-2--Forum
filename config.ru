require_relative 'server'
require 'rest-client'
require 'json'

use Rack::MethodOverride

run App::Server
