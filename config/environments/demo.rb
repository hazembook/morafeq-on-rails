require_relative "production"

Rails.application.configure do
  config.hosts = [
    "morafeq.hazembook.com",
    /\A.*\.morafeq\.hazembook\.com\z/
  ]
end
