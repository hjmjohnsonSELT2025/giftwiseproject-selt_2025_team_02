# app/services/gift_offer_lookup_service.rb
class GiftOfferLookupService
  SERP_API_ENDPOINT = "https://serpapi.com/search.json".freeze

  def initialize(gift)
    @gift = gift
  end

  def ensure_offers!(force: false)
    return if !force && @gift.gift_offers.exists?

    offers = lookup_offers_for(@gift.name)
    return if force && offers.blank?

    GiftOffer.transaction do
      @gift.gift_offers.destroy_all if force

      offers.each do |attrs|
        @gift.gift_offers.create!(attrs)
      end
    end
  end

  private

  def lookup_offers_for(name)
    # In test, always use the static catalog so Cucumber is deterministic
    if Rails.env.test?
      return static_catalog[name.downcase] || []
    end
    # 1) In dev/prod: Try external API (SerpApi Google Shopping)
    api_offers = fetch_offers_from_serpapi(name)
    return api_offers if api_offers.any?

    # 2) Fallback to static catalog so the app still works without API
    static_catalog[name.downcase] || []
  end

  # ---------------- SerpApi integration ----------------

  def fetch_offers_from_serpapi(name)
    api_key = ENV["SERPAPI_API_KEY"]
    return [] if api_key.blank?

    response = HTTP.get(
      SERP_API_ENDPOINT,
      params: {
        engine: "google_shopping",
        q:      name,
        api_key: api_key
      }
    )

    return [] unless response.status.success?

    body = JSON.parse(response.body.to_s)
    results = body["shopping_results"] || []

    # 1) Map raw SerpApi results to our attributes
    raw_offers = results.first(20).map do |item|
      {
        store_name: item["source"],
        price:      item["extracted_price"] || parse_price(item["price"]),
        currency:   "USD",
        rating:     item["rating"],
        url:        item["product_link"]
      }.compact
    end

    # 2) Group by store and keep the cheapest offer per store
    grouped = raw_offers
                .reject { |o| o[:store_name].blank? || o[:price].nil? }
                .group_by { |o| o[:store_name] }

    unique_best_per_store = grouped.map do |_store, offers_for_store|
      offers_for_store.min_by { |o| o[:price] }
    end

    # 3) Sort by price ascending and limit to 8 rows
    unique_best_per_store
      .sort_by { |o| o[:price] }
      .first(8)
  rescue StandardError => e
    Rails.logger.error("SerpApi lookup failed for '#{name}': #{e.class} - #{e.message}")
    []
  end

  # Handles cases where SerpApi gives price like "$19.99" instead of numeric
  def parse_price(raw_price)
    return nil if raw_price.nil?
    raw_price.to_s.gsub(/[^\d\.]/, "").to_f
  end

  # ---------------- Static fallback ----------------

  def static_catalog
    {
      "nike socks" => [
        {
          store_name: "Amazon",
          price:      11.99,
          currency:   "USD",
          rating:     4.6,
          url:        "https://www.amazon.com/s?k=nike+socks"
        }
      ]
    }
  end
end
