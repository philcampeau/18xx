# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class CompanyPendingPar < Base
      ACTIONS = %w[par].freeze

      def description
        'Choose Corporation Par Value'
      end

      def actions(entity)
        return [] unless current_entity == entity

        ACTIONS
      end

      def active?
        companies_pending_par.any?
      end

      def active_entities
        [@round.companies_pending_par.first&.owner].compact
      end

      def process_par(action)
        share_price = action.share_price
        corporation = action.corporation
        entity = action.entity

        @game.stock_market.set_par(corporation, share_price)
        @log << "#{entity.name} pars #{corporation.name} at #{@game.format_currency(share_price.price)}"

        unless corporation.president_share_granted_from_private
          @game.share_pool.buy_shares(entity, corporation.shares.first, exchange: :free)
        end

        if corporation.pending_capitalization_from_private_percent.positive? 
          @game.settle_pending_capitalization_from_private(corporation)
        end

        @game.after_par(corporation)
        corporation.president_share_granted_from_private = false
        corporation.pending_capitalization_from_private_percent = 0
        corporation.ipoed = true
        @round.companies_pending_par.shift
      end

      def companies_pending_par
        @round.companies_pending_par
      end

      def get_par_prices(_entity, _corp)
        @game
          .stock_market
          .par_prices
      end

      def round_state
        {
          companies_pending_par: [],
        }
      end
    end
  end
end
