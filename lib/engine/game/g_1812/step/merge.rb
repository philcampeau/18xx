# frozen_string_literal: true

require_relative '../../g_1867/step/merge'

module Engine
  module Game
    module G1812
      module Step
        class Merge < G1867::Step::Merge
          LIMIT_OWNED_BY_ONE_ENTITY = 4
          LIMIT_MERGE = 6

          def can_convert?(entity)
            entity.type == :minor && entity.share_price.price >= minimum_price
          end

          def convert_price(corporation)
            new_public_price(corporation.share_price.price)
          end

          def finish_convert(action)
            super
            target = action.corporation
            @game.share_pool.buy_shares(target.owner, target.shares.first.to_bundle, exchange: :free)
          end

          def finish_merge
            minimum = @game.format_currency(minimum_price)
            raise GameError, "Merge not allowed: highest plus lowest price is below #{minimum}" if price_sum < minimum_price

            super
          end

          def merged_par_price
            new_public_price(price_sum)
          end

          def finish_merge_to_major(action)
            target = action.corporation
            merging = @merging.sort
            price = merged_par_price
            allotment = share_allotment(target, merging, price.price)
            director = allotment.keys.max_by { |p| [allotment[p][:shares], -allotment.keys.index(p)] }
            raise GameError, 'Merge not allowed: no player would have two shares' if allotment[director][:shares] < 2

            @game.par_corporation(target, price)
            target.ipoed = true
            @round.entities[@round.entity_index] = target
            @merge_major = false
            allot_shares(target, allotment, director, price.price)

            merging.each do |corporation|
              remove_duplicate_tokens(target, @merging)
              move_tokens(corporation, target)
              receiving = move_assets(corporation, target)
              @game.close_corporation(corporation)
              @log << "#{corporation.name} merges into #{target.name} receiving #{receiving.join(', ')}"
              @round.entities.delete(corporation)
            end

            if tokens_above_limits?(target, @merging)
              @log << "#{target.name} will be above token limit and must decide which tokens to remove"
              @round.corporations_removing_tokens = [target] + @merging
            else
              @game.fix_token_count!(target)
            end

            @round.goto_entity!(target) unless @round.entities.empty?
            @merging = nil
            @round.converted = target
            @round.converts << target
            @round.merge_type = :merge
            holders = @game.players.select { |p| allotment.key?(p) }
            @round.share_dealing_players = holders.rotate(holders.index(director))
            @round.share_dealing_multiple = holders
          end

          private

          def minimum_price
            @game.stock_market.share_prices_with_types(%i[convert_range]).map(&:price).min
          end

          def price_sum
            @merging.map { |c| c.share_price.price }.minmax.sum
          end

          def new_public_price(price)
            row = @game.stock_market.market.first
            space = row[row.rindex { |sp| sp && sp.price <= price } - 4]
            [space, @game.stock_market.par_prices.max_by(&:price)].min_by(&:price)
          end

          def share_allotment(target, merging, price)
            counts = merging.map(&:owner).tally
            spare = target.total_shares - counts.values.sum { |n| (n * 1.5).floor }
            counts.to_h do |player, count|
              shares = (count * 1.5).floor
              next [player, { shares: shares }] if count.even?

              upgrade = spare.positive? && player.cash >= upgrade_cost(price)
              spare -= 1 if upgrade
              [player, { shares: shares + (upgrade ? 1 : 0), half: upgrade ? :upgrade : :downgrade }]
            end
          end

          def allot_shares(target, allotment, director, price)
            @game.share_pool.buy_shares(director, target.shares.first.to_bundle, exchange: :free)
            allotment.each do |player, plan|
              shares = target.shares.reject(&:president).take(plan[:shares] - (player == director ? 2 : 0))
              @game.share_pool.buy_shares(player, Engine::ShareBundle.new(shares), exchange: :free) unless shares.empty?
              settle_half_share(player, target, price, plan[:half])
            end
          end

          def upgrade_cost(price)
            (price.to_f / 2).ceil
          end

          def settle_half_share(player, target, price, half)
            case half
            when :upgrade
              cost = upgrade_cost(price)
              player.spend(cost, target)
              @log << "#{player.name} pays #{@game.format_currency(cost)} to upgrade a half share of #{target.name}"
            when :downgrade
              value = (price.to_f / 2).floor
              @game.bank.spend(value, player)
              @log << "#{player.name} receives #{@game.format_currency(value)} for a half share of #{target.name}"
            end
          end
        end
      end
    end
  end
end
