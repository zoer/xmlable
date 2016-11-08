class String
  module StripHeredoc
    def strip_heredoc
      indent = scan(/^[ \t]*(?=\S)/).min
      indent = indent.respond_to?(:size) ? indent.size : 0
      gsub(/^[ \t]{#{indent}}/, '')
    end
  end
  include StripHeredoc
end

