# frozen_string_literal: true

require_relative '../g_1846/game'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18MO
      class Game < G1846::Game
        attr_accessor :exchanged_share

        include_meta(G18MO::Meta)
        include G18MO::Entities
        include G18MO::Map

        STARTING_CASH = { 2 => 600, 3 => 400, 4 => 400, 5 => 385 }.freeze
        TILE_COST = 0

        PHASES = [
                {
                  name: '2',
                  train_limit: 4,
                  tiles: [:yellow],
                  operating_rounds: 2,
                  status: ['can_buy_companies'],
                },
                {
                  name: '3',
                  train_limit: 4,
                  on: 'G3',
                  tiles: %i[yellow green],
                  operating_rounds: 2,
                  status: ['can_buy_companies'],
                },
                {
                  name: '4',
                  train_limit: 4,
                  on: '3E',
                  tiles: %i[yellow green],
                  operating_rounds: 2,
                  status: ['can_buy_companies'],
                },
                {
                  name: '5',
                  on: '5',
                  train_limit: 3,
                  tiles: %i[yellow green brown],
                  operating_rounds: 2,
                },
                {
                  name: '6',
                  on: '5E',
                  train_limit: 3,
                  tiles: %i[yellow green brown],
                  operating_rounds: 2,
                },
                {
                  name: '7',
                  on: '7',
                  train_limit: 2,
                  tiles: %i[yellow green brown gray],
                  operating_rounds: 2,
                },
              ].freeze

        TRAINS = [
          {
            name: 'Y2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 100,
            obsolete_on: '3E',
            variants: [
              {
                name: 'Y3',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 150,
              },
              ],
          },
          {
            name: 'G3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 180,
            obsolete_on: '5E',
            variants: [
              {
                name: 'G4',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 220,
              },
            ],
          },
          {
            name: '3E',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 99 }],
            price: 300,
            obsolete_on: '5E',
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 450,
            variants: [
              {
                name: '6',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 540,
              },
            ],
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '5E',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 99 }],
            price: 700,
          },
          {
            name: '7',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 7, 'visit' => 7 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 700,
            variants: [
              {
                name: '8',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 8 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 800,
              },
            ],
          },
        ].freeze

        ORANGE_GROUP = [
        'Pool Share',
        'Extra Yellow Tile',
        'Extra Green Tile',
        'Tunnel Blasting Company',
        ].freeze

        BLUE_GROUP = [
        'Ranch Tile',
        'Train Discount',
        'Revenue Change',
        'Mountain Construction Company',
        ].freeze

        GREEN_GROUP = %w[ATSF MKT CBQ RI MP SSW SLSF].freeze
        MAIL_CONTRACT_BONUS = 10

        REMOVED_CORP_SECOND_TOKEN = {
          'ATSF' => 'H4',
          'SSW' => 'J8',
          'MKT' => 'E9',
          'RI' => 'G9',
          'MP' => 'D8',
          'CBQ' => 'C7',
          'SLSF' => 'E13',
        }.freeze

        # Two lays with one being an upgrade, second tile costs 20
        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: :not_if_upgraded, cost: 20 },
        ].freeze

        def setup
          super
          @exchange_share = nil
          add_teleport_destinations
        end

        def add_teleport_destinations
          @teleport_destination = {}
          @corporations.each do |corporation|
            ability = abilities(corporation, :token)
            next unless ability

            ability.hexes.each do |hex_id|
              @teleport_destination[hex_id] = corporation
              (hex = hex_by_id(hex_id)).location_name += " (#{corporation.name})"
              hex.tile.location_name += " (#{corporation.name})"
            end
          end
        end

        def remove_teleport_destination(corporation, city)
          hex = city.hex
          return if @teleport_destination[hex.id] != corporation && !out_of_slots?(city)

          @teleport_destination.delete(hex.id)
          hex.location_name = location_name(hex.id)
          hex.tile.location_name = location_name(hex.id)
        end

        # return true if all slots are filled and no upgrade can add a slot
        def out_of_slots?(city)
          tile = city.tile
          return false unless city.available_slots.zero?

          # doesn't handle case where upgrade tiles are gone
          tile.color == :gray || tile.color == :brown || (tile.color == :green && tile.label.to_s != 'Z') ||
            (tile.color == :yellow && tile.label.to_s == 'StL')
        end

        def init_round
          G18MO::Round::Draft.new(self, [G18MO::Step::DraftPurchase])
        end

        def operating_round(round_num)
          @round_num = round_num
          G1846::Round::Operating.new(self, [
            G1846::Step::Bankrupt,
            G18MO::Step::SpecialToken,
            Engine::Step::SpecialTrack,
            G1846::Step::BuyCompany,
            G1846::Step::IssueShares,
            G18MO::Step::TrackAndToken,
            Engine::Step::Route,
            G1846::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::SpecialBuyTrain,
            G18MO::Step::BuyTrain,
            [G1846::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18MO::Step::Exchange,
            G1846::Step::BuySellParShares,
          ])
        end

        def next_round!
          @draft_finished = true # always use 1846 MP next_round!
          super
        end

        def operating_order
          @minors.select(&:floated?) + @corporations.select(&:floated?).sort
        end

        def check_other(route)
          visited_hexes = {}
          route.visited_stops.each do |stop|
            hex = stop.hex
            raise GameError, 'Route cannot run to multiple cities in a hex' if visited_hexes[hex]

            visited_hexes[hex] = true
          end
        end

        def num_trains(train)
          num_players = @players.size

          case train[:name]
          when 'Y2'
            two_player? ? 7 : num_players + 4
          when 'G3'
            two_player? ? 4 : num_players
          when '3E', '5E'
            1
          when '5'
            two_player? ? 3 : num_players
          when '7'
            two_player? ? 3 : 8
          end
        end

        def num_removals(group)
          case group
          when ORANGE_GROUP, BLUE_GROUP
            case @players.size
            when 2, 4
              2
            when 3
              3
            else
              1
            end
          when GREEN_GROUP
            case @players.size
            when 2, 3
              2
            when 4
              1
            else
              0
            end
          end
        end

        def corporation_removal_groups
          [GREEN_GROUP]
        end

        def num_pass_companies(_players)
          0
        end

        def block_for_steamboat?
          false
        end

        def num_mail_stops(route)
          return route.visited_stops.size if route.train.distance.is_a?(Numeric)

          [route.train.distance[0]['pay'], route.visited_stops.size].min
        end

        def revenue_for(route, stops)
          revenue = stops.sum { |stop| stop.route_revenue(route.phase, route.train) }

          revenue += east_west_bonus(stops)[:revenue]

          if route.train.owner.companies.include?(mail_contract)
            longest = route.routes.max_by { |r| [num_mail_stops(r), r.train.id] }
            revenue += num_mail_stops(route) * self.class::MAIL_CONTRACT_BONUS if route == longest
          end

          revenue
        end

        def revenue_str(route)
          stops = route.stops
          stop_hexes = stops.map(&:hex)
          str = route.hexes.map do |h|
            stop_hexes.include?(h) ? h&.name : "(#{h&.name})"
          end.join('-')

          bonus = east_west_bonus(stops)[:description]
          str += " + #{bonus}" if bonus

          if route.train.owner.companies.include?(mail_contract)
            longest = route.routes.max_by { |r| [num_mail_stops(r), r.train.id] }
            str += ' + Mail Contract' if route == longest
          end

          str
        end

        def bundles_for_corporation(share_holder, corporation, shares: nil)
          shares = (shares || share_holder.shares_of(corporation).reject { |s| s == @exchanged_share })
            .sort_by { |h| [h.president ? 1 : 0, h.percent] }
          all_bundles_for_corporation(share_holder, corporation, shares: shares)
        end

        def place_second_token(corporation, two_player_only: true, deferred: true)
          super(corporation, two_player_only: two_player_only, deferred: false)
        end

        # override compute_stops to allow visiting dit in East St. Louis and replacing city/offboard
        # with its value
        #
        def compute_stops(route)
          visits = route.visited_stops
          distance = route.train.distance
          return [] if visits.empty?

          paying_distance = distance.find { |d| d['pay'].positive? }

          # Separate between city/offboard and dits (exception: E-trains)
          # There should only be one dit_stop at most
          normal_stops, dit_stops = visits.partition { |node| paying_distance['nodes'].include?(node.type) }

          # if no dit stops (or E-train)
          return super if dit_stops.empty?

          # return if not enough normal stops
          return visits if normal_stops.size < paying_distance['pay']

          # remove smallest normal stop that has less revenue than dit
          worst_stop = normal_stops.min_by { |stop| stop.route_revenue(route.phase, route.train) }
          visits.reject { |stop| stop == worst_stop }
        end

        def setup_turn
          1
        end

        def unowned_purchasable_companies
          []
        end
      end
    end
  end
end
