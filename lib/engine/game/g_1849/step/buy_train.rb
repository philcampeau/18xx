# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1849
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          attr_accessor :can_buy_token_event, :bonds_event, :e_tokens_event

          def setup
            super
          end

          def pass!
            super
            @game.reorder_corps if @moved_any
            @moved_any = false
          end

          def process_sell_shares(action)
            price_before = action.bundle.shares.first.price
            super
            return unless price_before != action.bundle.shares.first.price

            @game.moved_this_turn << action.bundle.corporation
            @moved_any = true
          end

          def can_sell?(entity, bundle)
            # Corporation must complete its first operating round before its shares can be sold
            corporation = bundle.corporation
            return false unless corporation.operated?
            return false if @round.current_operator == corporation && corporation.operating_history.size < 2

            super
          end

          def buyable_trains(entity)
            # Cannot buy E-train without E-token
            trains_to_buy = super.dup

            trains_to_buy = trains_to_buy.reject { |t| t.name == 'E' } unless @game.e_token?(entity)

            trains_to_buy.uniq
          end

          def process_buy_train(action)
            super

            if @game.phase.status.include?('can_buy_tokens') && @game.can_buy_tokens_event == false
              @log << '-- Corporations may now buy station tokens from other connected corporations --'
              @game.can_buy_tokens_event = true
            elsif @game.phase.status.include?('bonds') && @game.bonds_event == false
              @log << '-- Corporations can issue a single L.500 bond, with L.50 interest per OR --'
              @game.bonds_event = true
            elsif @game.phase.status.include?('e_tokens') && @game.e_tokens_event == false
              @log << '-- Corporations can buy E-tokens to allow the purchase of E-Trains --'
              @game.e_tokens_event = true
            end
          end
        end
      end
    end
  end
end
