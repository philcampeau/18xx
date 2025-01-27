# frozen_string_literal: true

require_relative 'base'
require_relative '../action/buy_shares'
require_relative '../action/par'
require_relative '../action/sell_shares'
require_relative '../step/buy_sell_par_shares'

module Engine
  module Round
    class Stock < Base
      def select_entities
        @game.players.reject(&:bankrupt)
      end

      def self.short_name
        'SR'
      end

      def name
        'Stock Round'
      end

      def setup
        skip_steps
        next_entity! unless active_step
      end

      def after_process(_action)
        return if active_step

        next_entity!
      end

      def next_entity!
        if finished?
          # Need to move entity round once more to be back to the priority deal player
          next_entity_index!

          finish_round
          return
        end

        next_entity_index!
        start_entity
      end

      def start_entity
        @steps.each(&:unpass!)
        @steps.each(&:setup)

        skip_steps
        next_entity! unless active_step
      end

      def finished?
        @game.finished || @entities.all?(&:passed?)
      end

      def stock?
        true
      end

      def show_auto?
        true
      end

      protected

      def finish_round
        corporations_to_move_price.sort.each do |corp|
          next unless corp.share_price

          old_price = corp.share_price

          sold_out_stock_movement(corp) if sold_out?(corp) && @game.sold_out_increase?(corp)

          pool_share_drop = @game.class::POOL_SHARE_DROP
          if pool_share_drop != :none && corp.num_market_shares.positive?
            case pool_share_drop
            when :down_block
              @game.stock_market.move_down(corp)
            when :down_share
              corp.num_market_shares.times { @game.stock_market.move_down(corp) }
            when :left_block
              @game.stock_market.move_left(corp)
            end
          end

          @game.log_share_price(corp, old_price)
        end
      end

      def corporations_to_move_price
        @game.corporations.select { |c| c.floated? && c.type != :minor }
      end

      def sold_out_stock_movement(corp)
        @game.sold_out_stock_movement(corp)
      end

      def sold_out?(corporation)
        @game.sold_out?(corporation)
      end

      def inspect
        "<#{self.class.name} Round #{@game.turn}>"
      end
    end
  end
end
