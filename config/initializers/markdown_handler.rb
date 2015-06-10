module ActionView
  module Template::Handlers
    # Rails template handler for Markdown
    class Markdown
      class_attribute :default_format
      self.default_format = Mime::HTML

      # @param template [ActionView::Template]
      # @return [String] Ruby code that when evaluated will return the rendered
      #   content
      def call(template)
        renderer = ::Redcarpet::Render::HTML.new(
          hard_wrap: true,
          with_toc_data: true,
          filter_html: true
        )
        options = Rails.application.config.redcarpet_markdown_options
        @markdown ||= Redcarpet::Markdown.new(renderer, options)
        "#{@markdown.render(template.source).inspect}.html_safe"
      end
    end
  end
end

ActionView::Template.register_template_handler(:md, ActionView::Template::Handlers::Markdown.new)
