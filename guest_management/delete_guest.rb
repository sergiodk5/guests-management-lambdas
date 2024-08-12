require 'json'
require_relative 'dynamodb_helper'
require_relative 'lambda_utils'

class DeleteGuestHandler
  def execute(event:, context:)
    puts "Starting function execution..."

    guest_id = event.dig('pathParameters', 'id')
    return LambdaUtils.missing_id_response unless guest_id

    deleted = DynamoDBHelper.delete_item(guest_id)
    return LambdaUtils.database_error_response('delete') unless deleted

    LambdaUtils.build_response(200, 'Guest deleted successfully')
  end
end
