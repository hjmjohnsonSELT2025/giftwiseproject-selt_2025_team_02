require "bundler/setup"
require "openai"
class AiChatService
  def initialize
    # Gets the key from the .env file
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
end