# frozen_string_literal: true
require 'optparse'

module Volundir
  class CLI
    def self.start(args)
      new(args).run
    end

    def initialize(args)
      @args = args
      @command = args.shift
      @ingots = {}
      discover_and_load_ingots!
    end

    def run
      case @command
      when 's', 'server'
        dispatch(:server, @args)
      when 'g', 'generate'
        dispatch(:generate, @args)
      when 'help', '-h', '--help', nil
        print_help
      else
        if @ingots.key?(@command)
          @ingots[@command].call(@args)
        else
          puts "Unknown command: #{@command}"
          print_help
          exit 1
        end
      end
    end

    private

    def discover_and_load_ingots!
      # 1. Loads all gems declared in the Gemfile.
      Bundler.require(:default)

      # 2. Scan the loaded gems for ingots with the prefix 'volundir-'.
      Gem.loaded_specs.each do |name, spec|
        next unless name.start_with?('volundir-')

        require name
        ingot_name = name.sub('volundir-', '')
        # Converts the gem name to a constant (e.g., volundir-server -> VolundirServer)
        const_name = spec.name.split('-').map(&:capitalize).join

        if Object.const_defined?(const_name)
          @ingots[ingot_name] = Object.const_get(const_name)
        end
      end

      # 3. Loads local ingots from the 'ingots/' folder (if they exist).
      Dir[File.expand_path('../../ingots/*/lib/*.rb', __dir__)].each do |file|
        require file
      end
    end

    def dispatch(action, args)
      # Delegate to the ingots that respond to this action.
      puts "Executing default action '#{action}' with arguments: #{args.inspect}"
    end

    def print_help
      puts <<~HELP
        Volundir CLI - Modular System Based on Ingots

        Usage:

        volundir <command> [options]

        Main commands:

          help Displays this help screen

        Loaded ingots: #{@ingots.keys.empty? ? 'None' : @ingots.keys.join(', ')}
      HELP
    end
  end
end
