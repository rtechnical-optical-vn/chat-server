Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(
      *ENV.fetch("CORS_ORIGIN", "http://localhost:3000")
        .split(",")
        .map(&:strip)
        .reject(&:empty?)
    )

    resource "*",
      headers: :any,
      methods: %i[get post patch options],
      expose: %w[Content-Type],
      credentials: true
  end
end
