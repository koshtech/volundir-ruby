#!/usr/bin/env ruby
# frozen_string_literal: true

KOSHTECH_HOME         = ENV['KOSHTECH_HOME']
KOSHTECH_CONFIG       = ENV['KOSHTECH_CONFIG']
INGOTS_ROOT           = ENV['INGOTS_ROOT']
VOLUNDIR_ENV          = ENV['VOLUNDIR_ENV']
VOLUNDIR_ROOT         = ENV['VOLUNDIR_ROOT']
VOLUNDIR_CONFIG_PATH  = ENV['VOLUNDIR_CONFIG_PATH']
VOLUNDIR_INGOTS_PATH  = ENV['VOLUNDIR_INGOTS_PATH']
VOLUNDIR_LOCALES_PATH = ENV['VOLUNDIR_LOCALES_PATH']
VOLUNDIR_DEBUG        = ENV['VOLUNDIR_DEBUG']
SHELL_ROOT            = ENV['SHELL_ROOT']
RUBY_ROOT             = ENV['RUBY_ROOT']
JS_ROOT               = ENV['JS_ROOT']
ASSETS_ROOT           = ENV['ASSETS_ROOT']
APPS_ROOT             = ENV['APPS_ROOT']

begin
  # Load Bundler to ensure all dependencies/ingots are available.
  ENV['BUNDLE_GEMFILE'] ||= File.join(KOSHTECH_HOME, 'Gemfile')
  require 'bundler/setup'
  require 'debug' if ['development', 'test'].include?(VOLUNDIR_ENV)

  require_relative "#{RUBY_ROOT}/base/volundir_base.rb"
  volundir_required "cli/volundir"
rescue LoadError => e
  warn "Error starting CLI: #{e.message}"
  warn "Execute 'bundle install' before running the command."

  exit 1
end

Volundir::CLI.start(ARGV)
