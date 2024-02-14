# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Tube
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        # GAME_TITLE = '18 London Tube'
        GAME_DESIGNER = 'David Digby'
        GAME_LOCATION = 'London, England'
        GAME_RULES_URL = 'https://docs.google.com/document/d/1_SFGfaX-E5gBNrbkZ-ZT-1JcyNomO3xohj8WThvQs7I/'

        PLAYER_RANGE = [2, 6].freeze
      end
    end
  end
end
