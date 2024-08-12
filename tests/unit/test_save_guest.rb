require 'minitest/autorun'
require 'aws-sdk-dynamodb'
require 'json'
require_relative '../../guest_management/save_guest'

class TestSaveGuest < Minitest::Test
  def setup
    # Stub DynamoDB client
    @mock_dynamodb = Minitest::Mock.new
    # Mocking the Aws::DynamoDB::Client.new call to return our mock
    Aws::DynamoDB::Client.stub :new, @mock_dynamodb do
      @handler = method(:save_guest_handler)
    end
  end

  def test_save_guest_success
    # Expect the put_item method to be called with any hash and return a successful response
    @mock_dynamodb.expect :put_item, OpenStruct.new, [Hash]

    event = {
      'body' => '{"guest":{"fullName":"John Doe","attending":true,"participants":[{"fullName":"Jane Doe","minor":false}]}}'
    }
    context = {} # Mock context

    Aws::DynamoDB::Client.stub :new, @mock_dynamodb do
      response = @handler.call(event: event, context: context)
      assert_equal 200, response[:statusCode]

      # Parse the response body and compare the parsed JSON
      body = JSON.parse(response[:body])
      assert_equal 'Guest saved successfully', body
    end

    @mock_dynamodb.verify
  end

  def test_save_guest_invalid_input
    event = {
      'body' => '{"guest":{"fullName":"John Doe"}}' # Missing 'attending'
    }
    context = {}

    response = @handler.call(event: event, context: context)
    assert_equal 400, response[:statusCode]
    body = JSON.parse(response[:body])
    assert_equal 'Invalid input data', body
  end

  def test_save_guest_invalid_json
    event = {
      'body' => 'Invalid JSON' # Not a JSON
    }
    context = {}

    response = @handler.call(event: event, context: context)
    assert_equal 400, response[:statusCode]
    body = JSON.parse(response[:body])
    assert_equal 'Invalid JSON format', body
  end
end
