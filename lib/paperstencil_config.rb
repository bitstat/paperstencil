module PaperstencilConfig
  def self.[](key)
    unless @config
      general_config = File.read(Rails.root.to_s + "/config/paperstencil.yml")
      @config = YAML.load(general_config)[Rails.env].symbolize_keys

      secret_file = "#{Dir.home}/.paperstencil/secret.yml"
      if not File.exists?(secret_file)
        raise "\n\n#{'#' * 80}\n\n Unable to locate #{secret_file}. See config/secret_template.yml for more details. \n\n#{'#' * 80} \n "
      end

      secret_config = File.read(secret_file)
      @config.merge!(YAML.load(secret_config).deep_symbolize_keys)
    end
    @config[key]
  end

  def self.[]=(key, value)
    @config[key.to_sym] = value
  end
end
