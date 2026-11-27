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

        it 'names the bypass rule as the reason' do
          expect { game.check_route_combination(bypassing) }
            .to raise_error(GameError, 'Only one train can bypass a tokened-out city')
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
