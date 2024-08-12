require_relative 'get_all_guests'
require_relative 'save_guest'
require_relative 'get_guest'
require_relative 'update_guest'
require_relative 'delete_guest'

def get_all_guests_handler(event:, context:)
  handler = GetAllGuestsHandler.new
  handler.execute(event: event, context: context)
end

def save_guest_handler(event:, context:)
  handler = SaveGuestHandler.new
  handler.execute(event: event, context: context)
end

def get_guest_handler(event:, context:)
  handler = GetGuestHandler.new
  handler.execute(event: event, context: context)
end

def update_guest_handler(event:, context:)
  handler = UpdateGuestHandler.new
  handler.execute(event: event, context: context)
end

def delete_guest_handler(event:, context:)
  handler = DeleteGuestHandler.new
  handler.execute(event: event, context: context)
end
