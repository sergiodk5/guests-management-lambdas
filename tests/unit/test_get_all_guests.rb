require 'minitest/autorun'
require 'aws-sdk-dynamodb'
require 'json'
require_relative '../../guest_management/get_all_guests'

class TestGetAllGuests < Minitest::Test
  def setup
    # Stub DynamoDB client
    @mock_dynamodb = Minitest::Mock.new
    # Mocking the Aws::DynamoDB::Client.new call to return our mock
    Aws::DynamoDB::Client.stub :new, @mock_dynamodb do
      @handler = method(:get_all_guests_handler)
    end
  end

  def test_get_all_guests_success
    # Expect the scan method to be called with any hash and return a mock response
    @mock_dynamodb.expect :scan, OpenStruct.new(items: [{'fullName' => 'John Doe', 'attending' => true}]), [Hash]

    event = {}
    context = {} # Mock context

    Aws::DynamoDB::Client.stub :new, @mock_dynamodb do
      response = @handler.call(event: event, context: context)
      assert_equal 200, response[:statusCode]

      # Parse the response body and verify the guests
      guests = JSON.parse(response[:body])
      assert_equal 1, guests.size
      assert_equal 'John Doe', guests[0]['fullName']
    end

    @mock_dynamodb.verify
  end

  def test_get_all_guests_dynamodb_error
    # Mock DynamoDB error
    @mock_dynamodb.expect :scan, proc { raise Aws::DynamoDB::Errors::ServiceError.new(nil, 'Some error') }, [Hash]

    event = {}
    context = {}

    Aws::DynamoDB::Client.stub :new, @mock_dynamodb do
      response = @handler.call(event: event, context: context)
      assert_equal 500, response[:statusCode]
      body = JSON.parse(response[:body])
      assert_equal 'Failed to retrieve guests from DynamoDB', body
    end
  end
end
