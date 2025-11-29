module GiftsHelper
  # Return a safe HTTP/HTTPS URL for a gift offer, or "#" if invalid.
  def safe_offer_url(offer)
    raw = offer.url.to_s
    return "#" if raw.blank?

    begin
      uri = URI.parse(raw)
      # Only allow http/https links
      return "#" unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

      uri.to_s
    rescue URI::InvalidURIError
      "#"
    end
  end
end
