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
      let(:routes) { AutoRouter.new(game).path(trains, corporation).first.values.flatten }

      def hex_names(route)
        route.visited_stops.map { |stop| stop.hex.name }
      end

      it 'lets the walk run through tokened-out cities' do
        expect(game.auto_router_blocking?).to be(false)
      end

      it 'finds a route through a tokened-out city to a tokened-out terminus' do
        expect(corporation.name).to eq('FYN')
        expect(routes).to(be_any { |r| hex_names(r).include?('G5') && hex_names(r).last == 'F2' })
      end

      it 'never bypasses more than one tokened-out city on a route' do
        expect(routes).not_to be_empty
        expect(routes).to(be_all do |route|
          route.visited_stops[1..-2].count { |stop| stop.city? && game.custom_blocks?(stop, corporation) } <= 1
        end)
      end

      context 'with two trains that can each bypass a tokened-out city' do
        let(:game) { Game.load(data, at_action: 144) }
        let(:router) { AutoRouter.new(game) }
        let(:by_train) { router.path(trains, corporation).first }
        let(:bypassing) do
          trains.select { |t| t.name == '3+2' }.map do |train|
            by_train[train].find { |route| game.tokened_out?(route) }
          end
        end

        it 'rejects the combination, as only one train may bypass' do
          expect(corporation.name).to eq('IOW')
          expect(bypassing).to all(be_truthy)
          expect(router.real_revenue(bypassing.map(&:clone))).to eq(-1)
        end

        it 'marks exactly the bypassing routes as exclusive' do
          all = by_train.values.flatten

          expect(all).not_to be_empty
          expect(all.select(&:exclusive)).to all(satisfy { |route| game.tokened_out?(route) })
          expect(all.reject(&:exclusive)).to all(satisfy { |route| !game.tokened_out?(route) })
          expect(bypassing).to all(have_attributes(exclusive: true))
        end

        it 'names the bypass rule as the reason' do
          expect { game.check_route_combination(bypassing) }
            .to raise_error(GameError, 'Only one train can bypass a tokened-out city')
        end
      end

      it 'only builds routes that begin and end at a station' do
        expect(routes).not_to be_empty
        expect(routes).to(be_none { |r| r.visited_stops.first.halt? || r.visited_stops.last.halt? })
      end

      it 'skips connections that begin or end at a halt' do
        halt_route = nil
        game.hexes.each do |hex|
          hex.tile.towns.select(&:halt?).each do |halt|
            halt_route ||= { left: halt, right: corporation.tokens.first.city, chain: { nodes: [], paths: [] } }
          end
        end

        expect(game.auto_router_skip_connection?([halt_route])).to be(true)
        expect(game.auto_router_skip_connection?([halt_route.merge(left: halt_route[:right], right: halt_route[:left])]))
          .to be(true)
        expect(game.auto_router_skip_connection?([halt_route.merge(left: halt_route[:right])])).to be(false)
      end

      describe 'bitfield for in-tile paths between stations' do
        let(:router) { AutoRouter.new(game) }
        let(:paths) { game.hex_by_id('F2').tile.paths.select { |p| p.nodes.size > 1 } }
        let(:first) { paths.first }
        let(:second) { paths.find { |p| p != first && !(p.nodes & first.nodes).empty? } }

        def bitfield(path, bits)
          connection = [{ left: path.nodes[0], right: path.nodes[1], chain: { nodes: path.nodes, paths: [path] } }]
          router.bitfield_from_connection(connection, bits)
        end

        it 'does not treat two different paths that share a station as the same track' do
          bits = Hash.new { |h, k| h[k] = 0 }
          a = bitfield(first, bits)
          b = bitfield(second, bits)

          expect(a.zip(b).sum { |x, y| x & (y || 0) }).to eq(0)
        end

        it 'treats the same path as the same track' do
          bits = Hash.new { |h, k| h[k] = 0 }
          a = bitfield(first, bits)
          b = bitfield(first, bits)

          expect(a).to eq(b)
          expect(a.sum).to be_positive
        end
      end

      it 'never re-enters a hex' do
        expect(routes).to(be_all do |route|
          hexes = route.ordered_paths.map(&:hex).chunk_while { |a, b| a == b }.map(&:first)
          hexes == hexes.uniq
        end)
      end
    end
  end
end
