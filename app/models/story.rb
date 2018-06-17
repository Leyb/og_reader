class Story < ActiveRecord::Base

  validates :canonical_url, uniqueness: true, presence: true

  def get_content
    response = Faraday.get(canonical_url)
    raise 'status not 200' unless response.status == 200
    response.body
  end

  def scrape_url
    html = get_content
    formatted_response html
  end

  def formatted_response(body)
    response = get_all_meta_tags(body)
    tags = response[:tags]
    tags.merge(
      scrape_status: response[:missing_tags].present? ? :pending : :done,
      updated_time: updated_at,
      id: id
    )
  end

  def get_meta_tag(doc, tag)
    og_tag = doc.at("meta[property=\"og:#{tag}\"]")
    return nil unless og_tag.present? && og_tag['content'].present?
    ['content']
    og_tag['content']
  end

  def get_all_meta_tags(body)
    doc = Nokogiri::HTML(body)
    tags = {}
    missing_tags = false
    %i(url type title image).each do |key|
      content = get_meta_tag(doc, key)
      tags.merge!(key => content)
      missing_tags = true if content.blank?
      %i(url type width height alt).each do |img_key|
        image_content = get_meta_tag(doc, "image:#{img_key}")
        tags[:image][img_key] = image_content
        missing_tags = true if image_content.blank?
      end if key == 'image'

      end
    {tags: tags, missing_tags: missing_tags}
  end

end
