# frozen_string_literal: true

module Gwirian
  module Saas
    module PlanLimitsBypass
      class << self
        def gwirian_com?(user)
          return false if user.nil?
          return false unless user.respond_to?(:email_address)

          user.email_address.to_s.downcase.end_with?("@gwirian.com")
        end
      end
    end
  end
end
