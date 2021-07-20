# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18Carolinas
      class Game < Game::Base
        include_meta(G18Carolinas::Meta)
        include Entities
        include Map

        attr_reader :corporation_power, :north_hexes, :power_progress, :south_hexes, :tile_groups

        register_colors(green: '#237333',
                        red: '#d81e3e',
                        blue: '#0189d1',
                        lightBlue: '#a2dced',
                        yellow: '#FFF500',
                        orange: '#f48221',
                        brown: '#7b352a')

        CERT_LIMIT = {
          2 => 24,
          3 => 20,
          4 => 16,
          5 => 13,
          6 => 11,
        }.freeze

        STARTING_CASH = {
          2 => 1200,
          3 => 800,
          4 => 600,
          5 => 480,
          6 => 400,
        }.freeze

        MARKET = [
          %w[0
             10
             20
             30
             40
             50
             60p
             70p
             80p
             90p
             100
             110
             125
             140
             160
             180
             200
             225
             250
             275
             300
             325
             350e],
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 1,
            num: 64,
          },
          {
            name: '3',
            distance: 3,
            price: 1,
            num: 40,
          },
          {
            name: '4',
            distance: 4,
            price: 1,
            num: 32,
          },
          {
            name: '5',
            distance: 5,
            price: 1,
            num: 24,
          },
          {
            name: '6',
            distance: 6,
            price: 1,
            num: 16,
          },
          {
            name: '7',
            distance: 7,
            price: 1,
            num: 16,
          },
          {
            name: '8',
            distance: 8,
            price: 1,
            num: 16,
          },
          {
            name: '9',
            distance: 9,
            price: 1,
            num: 8,
          },
          {
            name: '10',
            distance: 10,
            price: 1,
            num: 8,
          },
          {
            name: '11',
            distance: 11,
            price: 1,
            num: 8,
          },
          {
            name: '12',
            distance: 12,
            price: 1,
            num: 8,
          },
          {
            name: '13',
            distance: 13,
            price: 1,
            num: 8,
          },
          {
            name: '14',
            distance: 14,
            price: 1,
            num: 8,
          },
          {
            name: '15',
            distance: 15,
            price: 1,
            num: 8,
          },
          {
            name: '16',
            distance: 16,
            price: 1,
            num: 8,
          },
          {
            name: 'Convert',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 0,
            num: 1,
          },
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 2,
            tiles: ['yellow'],
            operating_rounds: 1,
          },
          {
            name: '3',
            train_limit: 2,
            tiles: %w[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            train_limit: 2,
            tiles: %w[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            train_limit: 3,
            tiles: %w[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '6',
            train_limit: 4,
            tiles: %w[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '7',
            train_limit: 5,
            tiles: %w[yellow green brown gray],
            operating_rounds: 3,
          },
          {
            name: '8',
            train_limit: 6,
            tiles: %w[yellow green brown gray],
            operating_rounds: 3,
          },
          {
            name: '8+',
            train_limit: 6,
            tiles: %w[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        PAR_BY_LAYER = {
          1 => 90,
          2 => 80,
          3 => 70,
          4 => 60,
        }.freeze

        TOKENS_BY_LAYER = {
          1 => 4,
          2 => 3,
          3 => 3,
          4 => 2,
        }.freeze

        NORTH_CORPORATIONS = %w[NCR SEA WNC WW].freeze
        SOUTH_CORPORATIONS = %w[CAR CSC SR WM].freeze

        CURRENCY_FORMAT_STR = '$%d'
        BANK_CASH = 6_000
        CAPITALIZATION = :full
        MUST_SELL_IN_BLOCKS = false
        MARKET_SHARE_LIMIT = 100
        SELL_BUY_ORDER = :sell_buy
        SELL_AFTER = :first
        PRESIDENT_SALES_TO_MARKET = true
        HOME_TOKEN_TIMING = :operating_round
        SOLD_OUT_INCREASE = false
        SELL_MOVEMENT = :none
        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one
        COMPANY_SALE_FEE = 30
        ADDED_TOKEN_PRICE = 100

        GAME_END_CHECK = { stock_market: :current_or, bank: :current_or, bankrupt: :immediate }.freeze

        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze

        MIN_TRAIN = {
          '2' => 2,
          '3' => 2,
          '4' => 2,
          '5' => 3,
          '6' => 4,
          '7' => 5,
          '8' => 6,
          '8+' => 6,
        }.freeze

        MAX_TRAIN = 16

        POWER_COST = {
          '2' => 30,
          '3' => 40,
          '4' => 50,
          '5' => 60,
          '6' => 70,
          '7' => 80,
          '8' => 90,
          '8+' => 100,
        }.freeze

        MAX_PROGRESS = 15

        C_TILES = %w[C1 C2 C3 C4 C5 C6 C7 C8 C9].freeze
        C7_HEXES = %w[D10 G9].freeze
        C8_HEXES = %w[G19 J12].freeze
        C8_ROTATION = 5

        def init_graph
          Graph.new(self, any_track: true)
        end

        def init_tile_groups
          [
            %w[1 1s],
            %w[2 2s],
            %w[3 3s],
            %w[4 4s],
            %w[5 5s],
            %w[6 6s],
            %w[7 7s],
            %w[8 8s],
            %w[9 9s],
            %w[55 55s],
            %w[56 56s],
            %w[57 57s],
            %w[58 58s],
            %w[C1 C2],
            %w[C3 C4],
            %w[12 12s],
            %w[13 13s],
            %w[14 14s],
            %w[15 15s],
            %w[16 16s],
            %w[19 19s],
            %w[20 20s],
            %w[23 23s],
            %w[24 24s],
            %w[25 25s],
            %w[26 26s],
            %w[27 27s],
            %w[28 28s],
            %w[29 29s],
            %w[87 87s],
            %w[88 88s],
            %w[C5 C6],
            %w[38],
            %w[39],
            %w[40],
            %w[41],
            %w[42],
            %w[43],
            %w[44],
            %w[45],
            %w[46],
            %w[47],
            %w[70],
            %w[C7],
            %w[C8],
            %w[C9],
          ]
        end

        def update_opposites
          by_name = @tiles.group_by(&:name)
          @tile_groups.each do |grp|
            next unless grp.size == 2

            name_a, name_b = grp
            num = by_name[name_a].size
            if num != by_name[name_b].size
              raise GameError, "Sides of double-sided tiles need to have same number (#{name_a}, #{name_b})"
            end

            num.times.each do |idx|
              tile_a = tile_by_id("#{name_a}-#{idx}")
              tile_b = tile_by_id("#{name_b}-#{idx}")

              tile_a.opposite = tile_b
              tile_b.opposite = tile_a
            end
          end
        end

        def init_share_pool
          SharePool.new(self, allow_president_sale: true)
        end

        def setup
          @tile_groups = init_tile_groups
          update_opposites
          @unused_tiles = []

          # find north and south hexes
          @north_hexes = []
          @south_hexes = []
          @hexes.each do |hex|
            tile = hex.tile
            @north_hexes << hex if tile.frame&.color == NORTH_COLOR || tile.frame&.color2 == NORTH_COLOR
            @south_hexes << hex if tile.frame&.color == SOUTH_COLOR || tile.frame&.color2 == SOUTH_COLOR
          end

          @highest_layer = 1
          # randomize layers (tranches) with one North and one South in each
          @layer_by_corp = {}
          @north_corps = @corporations.select { |c| NORTH_CORPORATIONS.include?(c.name) }.sort_by { rand }
          @south_corps = @corporations.select { |c| SOUTH_CORPORATIONS.include?(c.name) }.sort_by { rand }
          @north_corps.zip(@south_corps).each_with_index do |corps, idx|
            layer = idx + 1
            corps.each do |corp|
              @layer_by_corp[corp] = layer
              # add additional tokens for earlier layers
              (TOKENS_BY_LAYER[layer] - 2).times do |_t|
                corp.tokens << Token.new(corp, price: ADDED_TOKEN_PRICE)
              end
            end
          end

          # Distribute privates
          # Rules call for randomizing privates, assigning to players then reordering players
          # based on worth of private
          # Instead, just pass out privates from least to most expensive since player order is already
          # random
          sorted_companies = @companies.sort_by(&:value)
          @players.each_with_index do |player, idx|
            if idx < 4
              company = sorted_companies.shift
              @log << "#{player.name} receives #{company.name} and pays #{format_currency(company.value)}"
              player.spend(company.value, @bank)
              player.companies << company
              company.owner = player
            else
              corp = [@north_corps[0], @south_corps[0]][idx - 4]
              price = par_prices(corp)[0]
              @stock_market.set_par(corp, price)
              share = corp.ipo_shares.first
              @share_pool.buy_shares(player,
                                     share.to_bundle,
                                     exchange: nil,
                                     swap: nil,
                                     allow_president_change: true)
              after_par(corp)
            end
          end

          # initialize corp trains
          @corporation_trains = {}
          @corporations.each do |corp|
            @corporation_trains[corp] = nil
          end

          trains.each { |t| t.owner = nil }
          @conversion_train = trains.find { |t| t.name == 'Convert' }

          # initialize power
          @corporation_power = Hash.new(0)
          @power_progress = 0

          @bankrupted = {}
        end

        def trains
          @depot.trains
        end

        def place_home_token(corporation)
          super
          @graph.clear
        end

        def can_ipo?(corp)
          @layer_by_corp[corp] <= current_layer
        end

        def par_prices(corp)
          price = PAR_BY_LAYER[@layer_by_corp[corp]]
          stock_market.par_prices.select { |p| p.price == price }
        end

        def check_new_layer
          layer = current_layer
          @log << "-- Tranche #{layer} corporations now available --" if layer > @highest_layer
          @highest_layer = layer
        end

        def current_layer
          layers = @layer_by_corp.select do |corp, _layer|
            corp.num_ipo_shares.zero? || @bankrupted[corp]
          end.values
          layers.empty? ? 1 : [layers.max + 1, 4].min
        end

        def init_round
          @log << "-- #{round_description('Stock', 1)} --"
          @round_counter += 1
          stock_round
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            G18Carolinas::Step::BuySellParSharesCompanies,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            G18Carolinas::Step::Bankrupt,
            Engine::Step::HomeToken,
            G18Carolinas::Step::Track,
            G18Carolinas::Step::ConvertTrack,
            G18Carolinas::Step::Token,
            G18Carolinas::Step::Route,
            G18Carolinas::Step::Dividend,
            G18Carolinas::Step::BuyPower,
          ], round_num: round_num)
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          standard = to.paths.any? { |p| p.track == :broad }
          southern = to.paths.any? { |p| p.track != :broad }

          north = @north_hexes.include?(from.hex)
          south = @south_hexes.include?(from.hex)

          # Can only ever lay standard track in the North or anywhere after phase 5
          return false if ((north && !south) || @phase.available?('5')) && southern

          # Can only ever lay southern track in the South before phase 5
          return false if !north && south && standard && !@phase.available?('5')

          # handle C tiles specially
          return false if from.label.to_s == 'C' && to.color == :yellow && from.cities.size != to.cities.size

          # correct color progression?
          return false unless Engine::Tile::COLORS.index(to.color) == (Engine::Tile::COLORS.index(from.color) + 1)

          # honors pre-existing track?
          return false unless paths_are_subset_of?(from, to.paths)

          # If special ability then remaining checks is not applicable
          return true if special

          # correct label?
          return false unless upgrades_to_correct_label?(from, to)

          # honors existing town/city counts?
          # - allow labelled cities to upgrade regardless of count; they're probably
          #   fine (e.g., 18Chesapeake's OO cities merge to one city in brown)
          # - TODO: account for games that allow double dits to upgrade to one town
          return false if from.towns.size != to.towns.size
          return false if !from.label && from.cities.size != to.cities.size

          # handle case where we are laying a yellow OO tile and want to exclude single-city tiles
          return false if (from.color == :white) && from.label.to_s == 'OO' && from.cities.size != to.cities.size

          true
        end

        # allow standard to upgrade southern after phase 5
        def paths_are_subset_of?(tile, other_paths)
          return tile.paths_are_subset_of?(other_paths) unless @phase.available?('5')

          Engine::Tile::ALL_EDGES.any? do |ticks|
            tile.paths.all? do |path|
              path = path.rotate(ticks)
              other_paths.any? { |other| path_subset?(path, other) }
            end
          end
        end

        def path_subset?(path, other)
          other_ends = other.ends
          path.ends.all? { |t| other_ends.any? { |o| t <= o } }
        end

        def update_tile_lists!(tile, old_tile)
          @tiles.delete(tile)
          if tile.opposite
            @tiles.delete(tile.opposite)
            @unused_tiles << tile.opposite
          end

          return if old_tile.preprinted

          @tiles << old_tile
          return unless old_tile.opposite

          @unused_tiles.delete(old_tile.opposite)
          @tiles << old_tile.opposite
        end

        def flip_tile!(hex)
          old = hex.tile
          return if old.color != :yellow && old.color != :green
          return if C_TILES.include?(old.name)

          new = old.opposite
          @log << "Flipping tile #{old.name} to #{new.name} in hex #{hex.id}"

          new.rotate!(old.rotation)
          update_tile_lists(new, old)
          hex.lay(new)
        end

        def sorted_corporations
          @corporations.sort_by { |c| @layer_by_corp[c] }
        end

        def corporation_available?(entity)
          entity.corporation? && can_ipo?(entity)
        end

        def status_array(corp)
          layer_str = "Tranche #{@layer_by_corp[corp]}"
          layer_str += ' (N/A)' unless can_ipo?(corp)

          prices = par_prices(corp).map(&:price).sort
          par_str = ("Par #{prices[0]}" unless corp.ipoed)

          status = [[layer_str]]
          status << [par_str] if par_str
          status << %w[Receivership bold] if corp.receivership?

          status
        end

        def conversion_trains
          [@conversion_train]
        end

        def check_route_token(route, token)
          return if route.train.name == 'Convert'

          super
        end

        def buy_power(entity, delta, cost, ebuy: false)
          if !ebuy && @power_progress + delta > MAX_PROGRESS
            @power_progress = ((@power_progress - 1 + delta) % MAX_PROGRESS) + 1
            advance_phase!
          elsif !ebuy
            @power_progress += delta
          end

          @corporation_power[entity] += delta
          entity.spend(cost, @bank)
        end

        def advance_phase!
          return if @phase.name == '8+'

          @phase.next!

          # reduce corporation power
          @corporations.each do |corp|
            loss = (@corporation_power[corp] / 3).to_i
            @corporation_power[corp] -= loss
            @log << "#{corp.name} loses #{loss} power (to #{@corporation_power[corp]})" if loss.positive?
          end

          upgrade_c_hexes if @phase.name == '5'
        end

        def upgrade_c_hexes
          C7_HEXES.each do |hexid|
            hex = hex_by_id(hexid)
            tile = @tiles.find { |t| t.name == 'C7' }
            upgrade_tile(hex, tile, 0)
          end
          C8_HEXES.each do |hexid|
            hex = hex_by_id(hexid)
            tile = @tiles.find { |t| t.name == 'C8' }
            upgrade_tile(hex, tile, C8_ROTATION)
          end
        end

        # no checking
        def upgrade_tile(hex, tile, rotation)
          old_tile = hex.tile
          tile.rotate!(rotation)
          update_tile_lists(tile, old_tile)
          hex.lay(tile)
          @log << "Automatically upgrading hex #{hex.id} with tile #{tile.id}"
          @graph.clear
        end

        def min_train
          MIN_TRAIN[@phase.name]
        end

        def enough_power?(entity)
          return false unless entity.corporation?
          return true if entity.receivership?

          !must_buy_power?(entity)
        end

        def loan_or_power(corp)
          corp.receivership? && must_buy_power?(corp) ? min_train : @corporation_power[corp]
        end

        def route_trains(entity)
          # remember single train if in receivership
          if entity.receivership? && must_buy_power?(entity) && !entity.trains.empty?
            first = entity.trains.first
            entity.trains.clear
            entity.trains << first if first.distance == min_train
          end

          # if no trains, and legal to run a train, allocate a minimum size train
          if entity.trains.empty? && (@corporation_power[entity] >= min_train ||
              (entity.receivership? && must_buy_power?(entity)))
            new_train = trains.find { |t| t.distance == min_train && !t.owner }
            raise GameError, "Unable to allocate train of distance #{min_train}" unless new_train

            new_train.owner = entity
            entity.trains << new_train
          end

          entity.trains
        end

        # after running routes, update trains in corp. This is needed when loading
        def update_route_trains(entity, routes)
          entity.trains.clear
          routes.each do |route|
            next if route.visited_stops.empty?

            route.train.owner = entity
            entity.trains << route.train
          end
          @corporation_trains[entity] = nil
        end

        def adjustable_train_list?
          true
        end

        def adjustable_train_sizes?
          true
        end

        def reset_adjustable_trains!(routes)
          entity = routes[0].train.owner
          raise GameError, 'Unable to find owner' unless entity

          return unless @corporation_trains[entity]

          entity.trains.each { |t| t.owner = nil }
          entity.trains.clear
          @corporation_trains[entity].each do |t|
            t.owner = entity
            entity.trains << t
          end
        end

        def add_route_train(routes)
          entity = routes[0].train.owner
          raise GameError, 'Unable to find owner' unless entity

          current_distance = entity.trains.sum(&:distance)
          return false if @corporation_power[entity] - current_distance < min_train
          return false if entity.receivership? && must_buy_power?(entity)

          @corporation_trains[entity] ||= entity.trains.dup

          new_train = trains.find { |t| t.distance == min_train && !t.owner }
          raise GameError, "Unable to allocate train of distance #{min_train}" unless new_train

          new_train.owner = entity
          entity.trains << new_train
          true
        end

        def delete_route_train(route)
          train = route.train
          entity = train.owner
          raise GameError, 'Unable to find owner' unless entity

          return false if train.owner.receivership? && must_buy_power?(entity)
          return false if entity.trains.one?

          @corporation_trains[entity] ||= entity.trains.dup

          train.owner = nil
          entity.trains.delete(train)
          true
        end

        def increase_route_train(route)
          train = route.train
          entity = train.owner
          raise GameError, 'Unable to find owner' unless entity

          return if train.distance == MAX_TRAIN
          return if route.routes.sum { |r| r.train.distance } >= loan_or_power(entity)

          @corporation_trains[entity] ||= entity.trains.dup

          new_train = trains.find { |t| t.distance == (train.distance + 1) && !t.owner }
          raise GameError, "Unable to allocate train of distance #{train.distance + 1}" unless new_train

          train.owner = nil
          new_train.owner = entity
          entity.trains[entity.trains.find_index(train)] = new_train
          route.train = new_train
        end

        def decrease_route_train(route)
          train = route.train
          entity = train.owner
          raise GameError, 'Unable to find owner' unless entity

          return if train.distance == min_train

          @corporation_trains[entity] ||= entity.trains.dup

          new_train = trains.find { |t| t.distance == (train.distance - 1) && !t.owner }
          raise GameError, "Unable to allocate train of distance #{train.distance - 1}" unless new_train

          train.owner = nil
          new_train.owner = entity
          entity.trains[entity.trains.find_index(train)] = new_train
          route.train = new_train
        end

        def check_distance(route, visits)
          if route.train.name == 'Convert'
            raise GameError, 'Route must be specified' if visits.empty?
            raise GameError, 'Route cannot begin/end in a town' if visits.first.town? || visits.last.town?
          end

          super
        end

        def check_connected(route, token)
          return if route.train.name == 'Convert'

          super
        end

        def check_other(route)
          if route.train.name == 'Convert'
            raise GameError, 'Route must have Southern track' unless route.paths.any? { |p| p.track != :broad }
          else
            raise GameError, 'Train below minimum size' if route.train.distance < min_train
            raise GameError, 'Train w/o owner' unless route.train.owner

            if route.routes.sum { |r| r.train.distance } > loan_or_power(route.train.owner)
              raise GameError, 'Train sizes exceed train power'
            end

            track_types = {}
            route.paths.each { |path| track_types[path.track] = 1 }
            raise GameError, 'Train cannot use more than one gauge' if track_types[:narrow] && track_types[:broad]
          end
        end

        def current_power_cost
          POWER_COST[@phase.name]
        end

        def next_power_cost
          POWER_COST[next_phase_name]
        end

        def next_phase_name
          if @phase.name == '8+'
            '8+'
          else
            @phase.upcoming[:name]
          end
        end

        def must_buy_power?(corporation)
          @corporation_power[corporation] < min_train
        end

        def current_corporation_power(corporation)
          @corporation_power[corporation]
        end

        def trains_str(corporation)
          "Power: #{@corporation_power[corporation]}"
        end

        def can_go_bankrupt?(player, corporation)
          return false unless self.class::BANKRUPTCY_ALLOWED

          total_emr_buying_power(player, corporation) <
            (min_train - @corporation_power[corporation]) * current_power_cost * 2
        end

        def on_train_header
          'Power Cost'
        end

        def train_limit_header
          'Min Train'
        end

        def info_on_trains(phase)
          format_currency(POWER_COST[phase[:name]])
        end

        def train_power?
          true
        end

        def total_emr_buying_power(player, corporation)
          corporation.cash + emr_liquidity(player, corporation)
        end

        def emr_liquidity(player, emr_corp)
          total = player.cash
          total += player.shares_by_corporation.sum do |corporation, shares|
            next 0 if shares.empty?

            corporation == emr_corp ? value_for_sellable(player, corporation) : value_for_shares(player, corporation)
          end
          total += player.companies.sum { |company| company.value - COMPANY_SALE_FEE }
          total
        end

        def value_for_shares(player, corporation)
          max_bundle = bundles_for_corporation(player, corporation).max_by(&:price)
          max_bundle&.price || 0
        end

        def bankrupt_corporation!(corp)
          # un-IPO the corporation
          corp.share_price.corporations.delete(corp)
          corp.share_price = nil
          corp.par_price = nil
          corp.ipoed = false
          corp.unfloat!

          # return shares to IPO with no compensation
          corp.share_holders.keys.each do |share_holder|
            next if share_holder == corp

            shares = share_holder.shares_by_corporation[corp].compact
            corp.share_holders.delete(share_holder)
            shares.each do |share|
              share_holder.shares_by_corporation[corp].delete(share)
              share.owner = corp
              corp.shares_by_corporation[corp] << share
            end
          end
          corp.shares_by_corporation[corp].sort_by!(&:index)
          corp.share_holders[corp] = 100
          corp.owner = nil

          # remove any tokens for corporation placed on map and clear graph
          corp.tokens.each(&:remove!)
          @graph.clear

          @bankrupted[corp] = true

          @log << "#{corp.name} is bankrupt"
        end

        def company_sale_price(company)
          company.value - COMPANY_SALE_FEE
        end
      end
    end
  end
end
