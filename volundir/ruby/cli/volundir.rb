# frozen_string_literal: true

require 'debug' if ['development', 'test'].include?(ENV['VOLUNDIR_ENV'])

volundir_required 'base/ingot_base'
volundir_required 'runtime/registry'

module Volundir
  class CLI
    def self.start(args)
      new(args).run
    end

    def initialize(args)
      @args     = args
      @command  = args.shift
      @registry = Volundir::Runtime::Registry.new

      @registry.discover!
    end

    def run
      # It handles aliases and standard commands for Help.
      help_flags = ['help', '-h', '--help']

      if @command.nil? || help_flags.include?(@command) || help_flags.include?(@args.first)
        dispatch_help
        return
      end

      command_info = @registry.registered_commands[@command]

      if command_info
        ingot_class = Object.const_get(command_info[:const_name])
        action      = command_info[:action]

        ingot_class.send(action, @args)
      else
        puts "Unknown command: '#{@command}'"
        dispatch_help

        exit 1
      end
    end

    private

    def dispatch_help
      help_command = @registry.registered_commands['help']

      if help_command
        ingot_class = Object.const_get(help_command[:const_name])

        if @command
          exec_command = @registry.registered_commands[@command]
          ingot_name   = exec_command[:ingot_name]
        else
          ingot_name  = help_command[:ingot_name]
        end

        ingot_class.send(help_command[:action], ingot_name, @command, @args, @registry)
      else
        puts "Help system is unavailable (missing required 'volundir-help' ingot)."

        exit 1
      end
    end
  end
end
