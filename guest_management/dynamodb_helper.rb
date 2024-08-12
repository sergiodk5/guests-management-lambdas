require 'aws-sdk-dynamodb'
require 'securerandom'
require 'dotenv/load'

module DynamoDBHelper
  TABLE_NAME = 'Guests'

  def self.client
    @client ||= Aws::DynamoDB::Client.new(
      # endpoint: 'http://host.docker.internal:8000',
      # region: 'us-west-2',
      # access_key_id: 'fakeMyKeyId',
      # secret_access_key: 'fakeSecretAccessKey'
      endpoint: ENV['DYNAMODB_ENDPOINT'] || 'https://dynamodb.us-west-2.amazonaws.com', # default to AWS endpoint
      region: ENV['AWS_REGION'] || 'us-west-2',
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )
  end

  def self.get_item(id)
    puts "Getting item with ID: #{id}"
    client.get_item(
      table_name: TABLE_NAME,
      key: { 'id' => id }
    ).item
  rescue Aws::DynamoDB::Errors::ServiceError => e
    puts "DynamoDB error: #{e}"
    nil
  end

  def self.put_item(item)
    client.put_item(
      table_name: TABLE_NAME,
      item: item
    )
  rescue Aws::DynamoDB::Errors::ServiceError => e
    puts "DynamoDB error: #{e.message}"
    false
  end

  def self.update_item(id, updates)
    update_expression = "SET fullName = :fullName, attending = :attending, participants = :participants"
    expression_attribute_values = {
      ":fullName" => updates['fullName'],
      ":attending" => updates['attending'],
      ":participants" => updates['participants'] || []
    }

    client.update_item(
      table_name: TABLE_NAME,
      key: { 'id' => id },
      update_expression: update_expression,
      expression_attribute_values: expression_attribute_values
    )
  rescue Aws::DynamoDB::Errors::ServiceError => e
    puts "DynamoDB error: #{e.message}"
    false
  end

  def self.delete_item(id)
    client.delete_item(
      table_name: TABLE_NAME,
      key: { 'id' => id }
    )
  rescue Aws::DynamoDB::Errors::ServiceError => e
    puts "DynamoDB error: #{e.message}"
    false
  end

  def self.scan_items
    client.scan(table_name: TABLE_NAME).items
  rescue Aws::DynamoDB::Errors::ServiceError => e
    puts "DynamoDB error: #{e.message}"
    []
  end

  def self.generate_uuid
    SecureRandom.uuid
  end
end
