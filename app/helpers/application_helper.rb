module ApplicationHelper
  #Note from Nancy - I used Gemini to write this method - it formats the output of the LLM into proper markdown
  def markdown(text)
    return "" unless text.present?

    options = {
      filter_html:     true,
      hard_wrap:       true,
      link_attributes: { rel: 'nofollow', target: "_blank" },
      space_after_headers: true,
      fenced_code_blocks: true
    }

    extensions = {
      autolink:           true,
      superscript:        true,
      disable_indented_code_blocks: true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    # This turns the markdown into HTML and tells Rails it's safe to render
    markdown.render(text).html_safe
  end

end
