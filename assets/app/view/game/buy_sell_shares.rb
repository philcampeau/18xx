# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/corporation'
require 'view/game/sell_shares'

module View
  module Game
    class BuySellShares < Snabberb::Component
      include Actionable

      needs :corporation

      def render
        step = @game.round.active_step
        current_entity = step.current_entity

        ipo_share = @corporation.shares[0]
        pool_shares = @game.share_pool.shares_by_corporation[@corporation].group_by(&:percent).values.map(&:first)

        children = []

        if step.current_actions.include?('buy_shares')
          price_protection = step.price_protection if step.respond_to?(:price_protection)

          if ipo_share && step.can_buy?(current_entity, ipo_share)
            children << h(
              :button,
              { on: { click: -> { buy_share(current_entity, ipo_share) } } },
              "Buy #{@game.class::IPO_NAME} Share",
            )
          end

          # Put up one buy button for each buyable percentage share type in market.
          # In case there are more than one type of percentages in market or if shares are not the
          # standard percent (e.g. 5% in 18MEX), show percentage type on button.
          # Do skip president's share in case there are other shares available.
          buyables = pool_shares
            .select { |share| step.can_buy?(current_entity, share) }
            .reject { |share| share.president && pool_shares.size > 1 }
          buyables.each do |share|
            text = buyables.size > 1 || share.percent != @corporation.share_percent ? "#{share.percent}% " : ''
            children << h(:button,
                          { on: { click: -> { buy_share(current_entity, share) } } },
                          "Buy #{text}Market Share")
          end

          if price_protection
            children << h(
              :button,
              { on: { click: -> { buy_share(current_entity, price_protection.shares) } } },
              'Protect Shares',
            )
          end

          if ipo_share && (swap_share = step.swap_buy(current_entity, @corporation, ipo_share))
            puts("ipo_share = #{ipo_share.class} with price #{ipo_share.price}")
            reduced_price = @game.format_currency(ipo_share.price - swap_share.price)
            children << h(
              :button,
              { on: { click: -> { buy_share(current_entity, ipo_share, swap: swap_share) } } },
              "Buy #{@game.class::IPO_NAME} Share (#{reduced_price} + #{swap_share.percent}% Share)",
            )
          end

          pool_shares.each do |pool_share|
            next unless (swap_share = step.swap_buy(current_entity, @corporation, pool_share))

            puts("pool_share = #{pool_share.class} with price #{pool_share.price}")
            reduced_price = @game.format_currency(pool_share.price - swap_share.price)
            children << h(
              :button,
              { on: { click: -> { buy_share(current_entity, pool_share, swap: swap_share) } } },
              "Buy #{pool_share.percent}% Market Share (#{reduced_price} + #{swap_share.percent}% Share)",
            )
          end
        end

        if step.current_actions.include?('short') && step.can_short?(current_entity, @corporation)
          short = lambda do
            process_action(Engine::Action::Short.new(current_entity, corporation: @corporation))
          end

          children << h(
            :button,
            { on: { click: short } },
            'Short Share',
          )
        end

        # Allow privates to be exchanged for shares
        @game.companies.each do |company|
          company.abilities(:exchange) do |ability|
            next unless ability.corporation == @corporation.name
            next unless company.owner == current_entity

            prefix = "Exchange #{company.sym} for "

            if ability.from.include?(:ipo) && step.can_gain?(company.owner, ipo_share, exchange: true)
              children << h(:button, { on: { click: -> { buy_share(company, ipo_share) } } },
                            "#{prefix} an #{@game.class::IPO_NAME} share")
            end

            next unless ability.from.include?(:market)

            # Put up one exchange button for each exchangable percentage share type in market.
            pool_shares
              .select { |share| step.can_gain?(company.owner, share, exchange: true) }
              .each do |share|
              text = pool_shares.size > 1 ? "#{prefix} a #{share.percent}% Market Share" : "#{prefix} a Market Share"
              children << h(:button, { on: { click: -> { buy_share(company, share) } } }, text)
            end
          end
        end

        children << h(SellShares, player: current_entity, corporation: @corporation)

        h(:div, children)
      end

      def buy_share(entity, share, swap: nil)
        process_action(Engine::Action::BuyShares.new(entity, shares: share, swap: swap))
      end
    end
  end
end
