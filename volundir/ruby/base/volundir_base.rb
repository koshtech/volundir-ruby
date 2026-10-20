# frozen_string_literal: true

def volundir_required(file_path)
  required(RUBY_ROOT, file_path)
end

def required(required_root, file_path)
  path = "#{File.join(required_root, file_path)}.rb"

  require_relative path
end
