# frozen_string_literal: true

require_relative '../../../step/tokener'
require_relative '../../../step/token'

module Engine
  module Game
    module G1837
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            return [] unless entity == current_entity
            return [] unless multiple_tokens?(entity)

            Engine::Step::Token::ACTIONS
          end

          def auto_actions(entity)
            return unless multiple_tokens?(entity)

            [Engine::Action::Pass.new(entity)] unless can_place_token?(entity)
          end

          def can_place_token?(entity)
            # Cheaper to do the graph first, then check affordability
            current_entity == entity &&
              !(token = entity.next_token).nil? &&
              @game.graph.can_token?(entity) &&
              can_afford_token?(token, buying_power(entity))
          end

          def log_skip(entity)
            super if multiple_tokens?(entity)
          end

          def multiple_tokens?(entity)
            entity.tokens.size > 1
          end

          def can_afford_token?(token, cash)
            @game.graph.tokenable_cities(token.corporation).any? do |city|
              token_price(token, city.tile.hex) <= cash
            end
          end

          def token_price(token, hex)
            home_hex = @game.hex_by_id(token.corporation.coordinates)
            home_hex.distance(hex) * token.price
          end

          def adjust_token_price_ability!(_entity, token, hex, _city, special_ability: nil)
            token.price = token_price(token, hex)
            [token, nil]
          end
        end
      end
    end
  end
end
