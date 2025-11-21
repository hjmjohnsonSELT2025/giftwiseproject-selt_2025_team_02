Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'],
        {
            prompt: 'select_account'
        }
end

# Allow GET requests for starting OAuth (so simple links work)
OmniAuth.config.allowed_request_methods = [:get]
