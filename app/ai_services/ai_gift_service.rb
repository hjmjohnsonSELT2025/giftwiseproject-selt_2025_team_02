require "bundler/setup"
require "openai"
class AiGiftService
  def initialize(recipient)
    # Gets the key from the .env file
    @recipient = recipient
    @client = OpenAI::Client.new(api_key: ENV.fetch("OPENAI_API_KEY"))
  end

  def chat(prompt)
    response = @client.chat.completions.create(
      messages: [{ role: "user", content: prompt }],
      model: "gpt-5.1"
    )
    # Get only text, not entire JSON output
    response.choices[0].message.content
  end

  def suggest_gift
    # make a system prompt using the database data
    prompt = <<~PROMPT
      You are a helpful gift-giving assistant.
      I need a gift suggestion for my #{@recipient.relation} name #{@recipient.name}.
      They are #{@recipient.age} years old, they are a #{@recipient.gender}.

      They like #{@recipient.likes} and they dislike #{@recipient.dislikes}.
      Please suggest a short list of gift ideas, and for each idea please give a short explanation
      on why they might like it based on their profile. Keep the tone friendly, casual, and helpful.
    PROMPT

    response = @client.chat.completions.create(
      messages: [{ role: "user", content: prompt }],
      model: "gpt-5.1"
    )
    # Get only text, not entire JSON output
    response.choices[0].message.content
  end

end