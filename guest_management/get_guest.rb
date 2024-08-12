require 'json'
require_relative 'dynamodb_helper'
require_relative 'lambda_utils'

class GetGuestHandler
  def execute(event:, context:)
    puts "Starting function execution..."

    guest_id = event.dig('pathParameters', 'id')
    puts "Guest ID: #{guest_id}"
    return LambdaUtils.missing_id_response unless guest_id

    puts "Getting guest..."
    guest = DynamoDBHelper.get_item(guest_id)

    puts "Guest: #{guest}"
    return LambdaUtils.not_found_response unless guest

    LambdaUtils.build_response(200, guest)
  end
end
