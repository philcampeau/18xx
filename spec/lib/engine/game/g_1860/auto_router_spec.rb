# frozen_string_literal: true

require 'json'
require 'spec_helper'
require 'engine/auto_router'

module Engine
  describe Game::G1860::Game do
    describe 'auto-router' do
      let(:data) { JSON.parse(File.read(File.join(FIXTURES_DIR, '1860', '19354.json'))) }
      let(:game) { Game.load(data, at_action: 134) }
      let(:corporation) { game.current_entity }
      let(:trains) { game.route_trains(corporation).sort_by(&:price) }
      let(:router) { AutoRouter.new(game) }
      let(:by_train) { router.path(trains, corporation).first }
      let(:routes) { by_train.values.flatten }

      def hex_names(route)
        route.visited_stops.map { |stop| stop.hex.name }
      end

      it 'finds a route through a tokened-out city to a tokened-out terminus' do
        expect(corporation.name).to eq('FYN')
        expect(routes).to(be_any { |r| hex_names(r).include?('G5') && hex_names(r).last == 'F2' })
      end

      it 'only builds legal single routes' do
        expect(routes).not_to be_empty
        routes.each do |route|
          stops = route.visited_stops
          hexes = route.ordered_paths.map(&:hex).chunk_while { |a, b| a == b }.map(&:first)

          expect(game.bypassed_cities(route).size).to be <= 1
          expect(stops.first.halt? || stops.last.halt?).to be(false)
          expect(hexes).to eq(hexes.uniq)
        end
      end

      it 'skips connections that begin or end at a halt' do
        halt = game.hexes.flat_map { |hex| hex.tile.towns }.find(&:halt?)
        city = corporation.tokens.first.city

        expect(game.auto_router_skip_connection?([{ left: halt, right: city }])).to be_truthy
        expect(game.auto_router_skip_connection?([{ left: city, right: halt }])).to be_truthy
        expect(game.auto_router_skip_connection?([{ left: city, right: city }])).to be_falsey
      end

      context 'with two trains that can each bypass a tokened-out city' do
        let(:game) { Game.load(data, at_action: 144) }
        let(:bypassing) do
          trains.select { |t| t.name == '3+2' }.map { |train| by_train[train].find(&:exclusive) }
        end

        it 'marks exactly the bypassing routes as exclusive' do
          expect(corporation.name).to eq('IOW')
          expect(bypassing).to all(be_truthy)
          routes.each { |route| expect(route.exclusive).to eq(game.tokened_out?(route)) }
        end

        it 'rejects running both, as only one train may bypass' do
          expect(router.real_revenue(bypassing.map(&:clone))).to eq(-1)
          expect { game.check_route_combination(bypassing) }
            .to raise_error(GameError, 'Only one train can bypass a tokened-out city')
        end
      end

      describe 'bitfield for in-tile paths between stations' do
        let(:bits) { Hash.new { |h, k| h[k] = 0 } }
        let(:paths) { game.hex_by_id('F2').tile.paths.select { |p| p.nodes.size > 1 } }
        let(:first) { paths.first }
        let(:second) { paths.find { |p| p != first && first.nodes.intersect?(p.nodes) } }

        def bitfield(path)
          router.bitfield_from_connection([{ left: path.nodes[0], right: path.nodes[1], chain: { paths: [path] } }], bits)
        end

        it 'does not treat two paths that share a station as the same track' do
          expect(bitfield(first).zip(bitfield(second)).map { |a, b| a & b.to_i }).to all(be_zero)
        end

        it 'treats the same path as the same track' do
          expect(bitfield(first)).to eq(bitfield(first))
          expect(bitfield(first).sum).to be_positive
        end
      end
    end
  end
end
