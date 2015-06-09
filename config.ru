require 'rubygems'
require 'bundler'
require 'rest-client'
require 'json'

Bundler.require(:default, ENV['RACK_ENV'] || 'development')
require_relative 'server'

use Rack::MethodOverride

run App::Server





