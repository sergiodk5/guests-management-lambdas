require 'json'
require_relative 'dynamodb_helper'
require_relative 'lambda_utils'

class SaveGuestHandler
  def execute(event:, context:)
    puts "Starting function execution..."

    guest_data = LambdaUtils.parse_json(event['body'])&.dig('guest')
    return LambdaUtils.invalid_json_response unless guest_data
    return LambdaUtils.invalid_input_response unless valid_guest_data?(guest_data)

    guest_id = DynamoDBHelper.generate_uuid
    guest_data['id'] = guest_id

    saved = DynamoDBHelper.put_item(guest_data)
    return LambdaUtils.database_error_response('save') unless saved

    LambdaUtils.build_response(200, { message: 'Guest successfully added', id: guest_id })
  end

  private

  def valid_guest_data?(guest)
    guest['fullName'] && guest['attending']
  end
end
