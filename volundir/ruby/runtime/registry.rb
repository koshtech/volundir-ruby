# frozen_string_literal: true
require 'json'

module Volundir
  module Runtime
    class Registry
      attr_reader :loaded_ingots, :registered_commands

      def initialize
        @manifests           = {}
        @loaded_ingots       = {}
        @registered_commands = {}
      end

      def discover!
        # 1. Discover local ingots in VOLUNDIR_INGOTS_PATH}/ingots/
        Dir[File.expand_path("#{VOLUNDIR_INGOTS_PATH}/*.json", __dir__)].each do |manifest_file|
          next unless File.exist?(manifest_file)

          manifest   = JSON.parse(File.read(manifest_file))
          name       = manifest['name']
          ingot_dir  = "#{INGOTS_ROOT}/#{name}"

          @manifests[name] = {
            dir: ingot_dir,
            manifest_file: manifest_file,
            manifest: manifest
          }
        end

        resolve_dependencies_and_load!
      end

      private

      def resolve_dependencies_and_load!
        # Validate dependencies across all discovered manifests
        @manifests.each do |name, data|
          deps    = data[:manifest]['dependencies'] || []
          missing = deps.reject { |dep| @manifests.key?(dep) }

          unless missing.empty?
            raise "Ingot '#{name}' missing dependencies: #{missing.join(', ')}"
          end
        end

        # Load ingots and register commands based on JSON metadata
        @manifests.each do |name, data|
          dir      = RUBY_ROOT
          manifest = data[:manifest]

          @loaded_ingots[name] = { dir: dir,manifest: manifest }

          # Load controllers and register commands defined in JSON
          commands = manifest['comands'] || []

          commands.each do |cmd|
            controller_path = File.join(dir, cmd['controller'])

            if File.exist?(controller_path)
              require_relative controller_path
            else
              raise "Controller file not found for command '#{cmd['name']}' at: #{controller_path}"
            end

            const_name = cmd["const_name"] || name.split('-').map(&:capitalize).join('::')

            @loaded_ingots[name][:const_name] = const_name

            command_info = {
              name: cmd['name'],
              aliases: cmd['aliases'] || [],
              description: cmd['description'],
              action: cmd['action'],
              ingot_name: name,
              const_name: const_name
            }

            @registered_commands[cmd['name']] = command_info
            (cmd['aliases'] || []).each do |alias_name|
              @registered_commands[alias_name] = command_info
            end
          end
        end
      end
    end
  end
end
