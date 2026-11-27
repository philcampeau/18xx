# frozen_string_literal: true

require 'spec_helper'
require 'view/game/game_info'

describe View::Game::GameInfo do
  let(:game) { Engine::Game::G1817::Game.new(%w[a b c]) }
  let(:component) { described_class.new(nil, game: game) }
  let(:nodes) { [] }

  before do
    game.singleton_class.send(:public, :info_available_train, :info_train_name, :info_train_price)
    allow(component).to receive(:h) do |tag, props = {}, children = nil|
      children = props unless props.is_a?(Hash)
      nodes << [tag, children]
      [tag, children]
    end
    component.instance_variable_set(:@depot, game.depot)
  end

  def quantity_for_two_trains
    nodes.clear
    component.send(:trains)
    index = nodes.index { |tag, children| tag == :td && children.to_s.delete('→') == '2' }
    nodes[index + 2][1]
  end

  it 'shows infinity for unlimited trains while they remain' do
    expect(quantity_for_two_trains).to eq('∞')
  end

  it 'shows zero for unlimited trains once they are all exported' do
    game.depot.export_all!('2')

    expect(quantity_for_two_trains).to eq('0')
  end
end
