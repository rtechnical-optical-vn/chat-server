class ApplicationController < ActionController::API
  private

  def render_json(data = nil, http_status: :ok, **payload)
    render json: (data || payload), status: http_status
  end
end
