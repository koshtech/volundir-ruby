#!/usr/bin/env ruby
# frozen_string_literal: true

KOSHTECH_HOME=ENV['KOSHTECH_HOME']
RUBY_ROOT=ENV['RUBY_ROOT']
RUBY_CLI="#{RUBY_ROOT}/cli"
RUBY_RUNTIME="#{RUBY_ROOT}/runtime"

begin
  # Load Bundler to ensure all dependencies/ingots are available.
  ENV['BUNDLE_GEMFILE'] ||= File.join(KOSHTECH_HOME, 'Gemfile')
  require 'bundler/setup'
  require "#{RUBY_CLI}/volundir"
rescue LoadError => e
  warn "Error starting CLI: #{e.message}"
  warn "Execute 'bundle install' before running the command."

  exit 1
end

Volundir::CLI.start(ARGV)
