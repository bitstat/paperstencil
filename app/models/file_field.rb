class FileField < Field
  def validate_field(field)
    if value["required"] and field.nil?
      @error = "This field is required. Please select a file."
      return false
    end
    true
  end

  def field_instance(field)
    v = {}
    if field
      v['file_name'] = field.original_filename
      v['type'] = field.content_type

      dir_path = PaperstencilConfig[:upload_path]
      new_file_path = File.join(dir_path, SimpleUUID::UUID.new.to_guid)
      FileUtils.mkdir_p(dir_path)
      FileUtils.cp(field.tempfile, new_file_path)
      v['file_path'] = new_file_path
    end
    v
  end
end
