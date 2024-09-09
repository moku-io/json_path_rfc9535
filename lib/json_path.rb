require_relative 'json_path/doc'

module JsonPath
  def self.Doc json_string
    Doc.new json_string
  end
end
