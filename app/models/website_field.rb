require 'uri'

class WebsiteField < Field

  def uri_validator
    @uri_validator ||= URI::regexp(['http', 'https', 'ftp'])
  end

  def validate_field(field)
    field.strip!

    if value["required"] and field.empty?
      @error = "This field is required. Please enter a value."
      return false
    end

    if (not field.empty?) and (not uri_validator =~ field)
      @error = "Please enter a valid url in http://website.com format."
      return false
    end

    true
  end

  def field_instance(field)
    field.to_s.strip
  end
end
