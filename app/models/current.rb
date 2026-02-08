class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :workspace

  delegate :user, to: :session, allow_nil: true
end
