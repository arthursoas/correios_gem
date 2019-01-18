class CorreiosException < StandardError
  def generate_exception(message)
    raise CorreiosException, format_error_message(message)
  end

  def format_error_message(message)
    message = message.to_s.gsub('(soap:Server)', '')
    message = message.strip
    message.capitalize
  end
end
