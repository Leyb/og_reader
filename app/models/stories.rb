class Stories < ActiveRecord::Base

  validates :canonical_url, uniqueness: true, presence: true

  def get_content
    puts "=====#{canonical_url}====="
    response = Faraday.get(canonical_url)
    raise 'status not 200' unless response.status == 200
    response.body
  end

  def og_tags(body)
    begin
      open_graph = OGP::OpenGraph.new(body)
    rescue
      return :error #not every site has all og
    end
    JSON.parse(open_graph.to_json)
  end

  def scrape_url
    html = get_content
    formated_response html
  end

  def formated_response(body)
    response = og_tags(body)
    return {scrape_status: :error} if response == :error
    response['image'] = response['images'].first['table']
    response.reject!{|k,v| %w(url type title image ).exclude?(k)}
    response.merge!(scrape_status: 'done', updated_time: updated_at, id: id)
  end

end
