require 'json'
require_relative 'dynamodb_helper'
require_relative 'lambda_utils'

class UpdateGuestHandler
  def execute(event:, context:)
    puts "Starting function execution..."

    guest_id = event.dig('pathParameters', 'id')
    return LambdaUtils.missing_id_response unless guest_id

    guest_updates = LambdaUtils.parse_json(event['body'])&.dig('guest')
    return LambdaUtils.invalid_json_response unless guest_updates
    return LambdaUtils.invalid_input_response unless valid_guest_data?(guest_updates)

    updated = DynamoDBHelper.update_item(guest_id, guest_updates)
    return LambdaUtils.database_error_response('update') unless updated

    LambdaUtils.build_response(200, 'Guest updated successfully')
  end

  private

  def valid_guest_data?(guest)
    guest['fullName'] && guest['attending']
  end
end
