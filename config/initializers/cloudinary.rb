Cloudinary.config do |config|
  config.secure = true
  config.cdn_subdomain = true
end

ActiveSupport.on_load(:active_storage_blob) do
  ActiveStorage::Blob.class_eval do
    def service_url_for_direct_upload(expires_in: 5.minutes)
      Cloudinary::Utils.cloudinary_api_url("upload",
        resource_type: "auto",
        type: "upload"
      ) + "?upload_preset=#{ENV['CLOUDINARY_UPLOAD_PRESET']}"
    end

    def service_headers_for_direct_upload
      { "Content-Type" => content_type, "X-Unique-Upload-Id" => key }
    end
  end
end
