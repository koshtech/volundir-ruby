# frozen_string_literal: true

module Volundir
  class IngotBase
    class << self
      attr_reader :commands, :root_path, :ingot_name

      def inherited(subclass)
        super
        subclass.instance_variable_set(:@commands, {})
      end

      def register_command(name, aliases: [], description: "", action: nil)
        command_info = {
          name: name,
          aliases: aliases,
          description: description,
          action: action,
          ingot: self
        }

        @commands[name.to_s] = command_info
        aliases.each do |a|
          @commands[a.to_s] = command_info
        end
      end

      def setup(root_path, ingot_name)
        @root_path = root_path
        @ingot_name = ingot_name
      end

      # Returns the help file based on the context and action
      # Structure: locales/<context>/<action_or_file>.(json|txt|yml)
      def locale_help_file(context, file_or_action, lang = 'en')
        base_dir = File.join(VOLUNDIR_LOCALES_PATH, context.to_s)

        candidates = [
          File.join(base_dir, "#{lang}", "#{file_or_action}.json"),
          File.join(base_dir, "#{file_or_action}.#{lang}.json"),
          File.join(base_dir, "#{file_or_action}.json"),
          File.join(base_dir, "#{file_or_action}.txt")
        ]

        candidates.find { |path| File.exist?(path) }
      end
    end
  end
end
