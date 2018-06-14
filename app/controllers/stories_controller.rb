class StoriesController < ActionController::Base
  # protect_from_forgery with: :exception

  def create
    url = params.permit(:url).to_h[:url]
    story = Stories.create( canonical_url: url  )
    render json: {id: story.id}
  end

  def show
    id = params.permit(:id).to_h[:id]
    story = Stories.find id
    response = story.scrape_url
    render json: response
  end

end
