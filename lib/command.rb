module Command

  def command_error?(response)
    return nil if response == ""
  end

  def command_to_list(response = "")
    response.split("\n").map(&:strip)
  end
end
