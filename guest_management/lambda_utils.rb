require 'json'

module LambdaUtils
  def self.parse_json(body)
    JSON.parse(body)
  rescue JSON::ParserError
    nil
  end

  def self.build_response(status_code, body)
    {
      statusCode: status_code,
      body: JSON.generate(body)
    }
  end

  def self.missing_id_response
    build_response(400, 'Guest ID is required')
  end

  def self.invalid_json_response
    build_response(400, 'Invalid JSON format')
  end

  def self.invalid_input_response
    build_response(400, 'Invalid input data')
  end

  def self.database_error_response(action)
    build_response(500, "Failed to #{action} item in DynamoDB")
  end

  def self.not_found_response
    build_response(404, 'Guest not found')
  end
end
