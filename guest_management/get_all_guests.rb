require 'json'
require_relative 'dynamodb_helper'
require_relative 'lambda_utils'

class GetAllGuestsHandler
  def execute(event:, context:)
    puts "Starting function execution..."

    guests = DynamoDBHelper.scan_items
    LambdaUtils.build_response(200, guests)
  end
end
