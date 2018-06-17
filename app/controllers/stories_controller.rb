class StoriesController < ActionController::Base
  # protect_from_forgery with: :exception

  def create
    url = params.permit(:url).to_h[:url]
    story = Story.create( canonical_url: url  )
    render json: {id: story.id}
  end

  def show
    id = params.permit(:id).to_h[:id]
    story = Story.find id
    response = story.scrape_url
    render json: response
  end

end
