$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'bundler/setup'
require 'ifirma'
require 'rspec'
require 'webmock/rspec'
