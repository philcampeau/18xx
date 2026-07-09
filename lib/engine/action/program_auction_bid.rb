# frozen_string_literal: true

require_relative 'program_enable'

module Engine
  module Action
    class ProgramAuctionBid < ProgramEnable
      attr_reader :bid_target, :enable_maximum_bid, :maximum_bid, :enable_buy_price, :buy_price, :auto_pass_after,
                  :enable_place_bid, :place_bid, :unconditional_pass

      def initialize(entity, bid_target: nil, maximum_bid: nil, buy_price: nil, enable_maximum_bid: false,
                     enable_buy_price: false, auto_pass_after: false, enable_place_bid: false, place_bid: nil,
                     unconditional_pass: false)
        super(entity)
        @bid_target = bid_target
        @enable_maximum_bid = enable_maximum_bid
        @maximum_bid = maximum_bid
        @enable_buy_price = enable_buy_price
        @buy_price = buy_price
        @auto_pass_after = auto_pass_after
        @enable_place_bid = enable_place_bid
        @place_bid = place_bid
        @unconditional_pass = unconditional_pass
      end

      def self.h_to_args(h, game)
        {
          bid_target: game.corporation_by_id(h['bid_target']) ||
                      game.company_by_id(h['bid_target']) ||
                      game.minor_by_id(h['bid_target']),
          enable_maximum_bid: h['enable_maximum_bid'],
          maximum_bid: h['maximum_bid'],
          enable_buy_price: h['enable_buy_price'],
          buy_price: h['buy_price'],
          auto_pass_after: h['auto_pass_after'],
          enable_place_bid: h['enable_place_bid'],
          place_bid: h['place_bid'],
          unconditional_pass: h['unconditional_pass'],
        }
      end

      def args_to_h
        {
          'bid_target' => @bid_target&.id,
          'enable_maximum_bid' => @enable_maximum_bid,
          'maximum_bid' => @maximum_bid,
          'enable_buy_price' => @enable_buy_price,
          'buy_price' => @buy_price,
          'auto_pass_after' => @auto_pass_after,
          'enable_place_bid' => @enable_place_bid,
          'place_bid' => @place_bid,
          'unconditional_pass' => @unconditional_pass,
        }
      end

      def to_s
        return "Place a bid of #{@place_bid} on #{@bid_target&.name}." if @enable_place_bid

        buy = @enable_buy_price ? "Buy if price at #{@buy_price}. " : ''
        bid = @enable_maximum_bid ? "Bid up to #{@maximum_bid}. " : ''
        pass = @unconditional_pass ? 'Pass. ' : ''
        suffix = @auto_pass_after ? 'Otherwise auto pass.' : ''

        "#{buy}#{bid}#{pass}#{suffix}"
      end

      def disable?(game)
        !game.round.auction?
      end
    end
  end
end
