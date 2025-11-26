require "bundler/setup"
require "openai"
class AiGiftService
  def initialize(recipient, force_refresh: false)
    # Gets the key from the .env file
    @recipient = recipient
    # force refresh flag for generating new AI suggestions, instead of relying on cached ones
    @force_refresh = force_refresh
    @client = OpenAI::Client.new(api_key: ENV.fetch("OPENAI_API_KEY"))
  end

  def chat(prompt)
    response = @client.chat.completions.create(
      messages: [ { role: "user", content: prompt } ],
      model: "gpt-5.1"
    )
    # get only text, not entire JSON output
    response.choices[0].message.content
  end

  def suggest_gift
    # create a unique cache key
    # if you change the recipient's likes and dislikes, the cache will
    # automatically expire and force new ideas
    cache_key = "recipient_gifts/#{@recipient.id}/#{@recipient.updated_at}"

    # if force_refresh is true then we want to delete the old cache first
    Rails.cache.delete(cache_key) if @force_refresh
    # check the cache
    Rails.cache.fetch(cache_key, expires_in: 7.days) do
      # make a system prompt using the database data
      prompt = <<~PROMPT
        You are a helpful gift-giving assistant.
        I need a gift suggestion for my #{@recipient.relation} name #{@recipient.name}.
        They are #{@recipient.age} years old, they are a #{@recipient.gender}.
        They like #{@recipient.likes} and they dislike #{@recipient.dislikes}.
        Please suggest a short list of gift ideas, and for each idea please give a short explanation
        on why they might like it based on their profile. Keep the tone friendly, casual, and helpful.

        I need a structured output from you. Please give it to me in the form of a JSON output, where the key
        for each gift is the name of the gift idea (keep it minimal), and the value is as verbose of a description as
        you want.
      PROMPT

      response = @client.chat.completions.create(
        messages: [ { role: "user", content: prompt } ],
        model: "gpt-4o",
        response_format: { type: "json_object" }
      )
      # get only text, not entire JSON output
      content = response.choices[0].message.content

      begin
        clean_content = content.gsub('```json', '').gsub('```', '').strip
        JSON.parse(clean_content)
      rescue JSON::ParserError
        { "Error" => "Could not generate gifts. Please try again." }
      end
    end

  end

  # Function to check if the AI for a recipient has cached suggestions, to determine
  # whether we should show a "Generate (refresh) new ideas" button, or "Generate ideas"
  def has_cached_suggestions?
    cache_key = "recipient_gifts/#{@recipient.id}/#{@recipient.updated_at}"
    #returns true if key exists, which implies that suggestions have been cached
    Rails.cache.exist?(cache_key)

  end

end



##
#
#         I need a structured output from you. Please give it to me in the form of a JSON output, where the key
#         for each gift is the name of the gift idea (keep it minimal), and the value is as verbose of a description as
#         you want.