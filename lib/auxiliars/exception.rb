class CorreiosException < StandardError
  def generate_exception(message)
    raise CorreiosException, message
  end
end
