class AiSuggestionsController < ApplicationController
  def index
  end

  def create
    user_input = params[:message]
    @response = AiChatService.new.chat(user_input)
    render :index
  end
end
