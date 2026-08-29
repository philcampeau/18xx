# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1835::Game do
  let(:player_1) { game.players.find { |player| player.id == 'a' } }
  let(:player_2) { game.players.find { |player| player.id == 'b' } }
  let(:player_3) { game.players.find { |player| player.id == 'c' } }
  let(:player_4) { game.players.find { |player| player.id == 'd' } }
  let(:player_5) { game.players.find { |player| player.id == 'e' } }
  let(:player_6) { game.players.find { |player| player.id == 'f' } }
  let(:player_7) { game.players.find { |player| player.id == 'g' } }

  def pass(entity)
    game.process_action(Engine::Action::Pass.new(entity)).maybe_raise!
  end

  def buy(player, company_id)
    game.process_action(Engine::Action::Bid.new(player, company: game.company_by_id(company_id),
                                                        price: game.company_by_id(company_id).value)).maybe_raise!
  end

  def buy_shares(player, corporation_id, percent = nil, other_player = nil)
    corp = game.corporation_by_id(corporation_id)
    unless other_player
      return game.process_action(Engine::Action::BuyShares.new(player,
                                                               shares: corp.shares.find(&:buyable))).maybe_raise!
    end

    game.process_action(Engine::Action::BuyShares.new(player, shares: other_player.shares_of(corp).find do |share|
      share.percent == percent
    end)).maybe_raise!
  end

  describe 'after_starter_pack_player_order_3' do
    let(:players) { %w[a b c] }
    let(:game) { Engine::Game::G1835::Game.new(players) }

    it 'should not move the PD if everyone passes' do
      3.times do |index|
        pass(game.players[index])
      end
      expect(game.players.first).to eq(player_1)
    end

    it 'should skip a player without money' do
      buy(player_1, 'NF') # player_1 down to 500
      pass(player_2)
      pass(player_3)
      buy(player_1, '1') # player_1 down to 420
      pass(player_2)
      pass(player_3)
      buy(player_1, 'LD') # player_1 down to 230
      pass(player_2)
      pass(player_3)
      buy(player_1, '2') # player_1 down to 60
      pass(player_2)
      pass(player_3)
      # player_1 is skipped, so the draft round ends
      expect(game.players.first).to eq(player_2)
    end
    it 'should skip two players without money' do
      buy(player_1, 'NF') # player_1 down to 500
      buy(player_2, '1') # player_2 down to 520
      pass(player_3)
      buy(player_1, 'LD') # player_1 down to 310
      buy(player_2, '2') # player_2 down to 350
      pass(player_3)
      buy(player_1, '3') # player_1 down to 230
      buy(player_2, '4') # player_2 down to 190
      pass(player_3)
      buy(player_1, 'BY_D') # player_1 down to 46
      buy(player_2, 'BB') # player_1 down to 60
      buy(player_3, 'HB')
      # player_1 is skipped
      # player_2 is skipped
      buy(player_3, '5')
      # player_1 is skipped
      # player_2 is skipped
      pass(player_3)
      expect(game.players.first).to eq(player_1)
    end
    it 'should set the PD properly after the full sale of the starter packet' do
      buy(player_1, 'NF')
      buy(player_2, '1')
      buy(player_3, 'LD')
      buy(player_1, '2')
      buy(player_2, '3')
      buy(player_3, '4')
      buy(player_1, 'BY_D')
      buy(player_2, 'HB')
      buy(player_3, '5')
      buy(player_1, 'BB')
      buy(player_2, '6')
      buy(player_3, 'PB')
      # player_1 is skipped
      buy(player_2, 'OBB')

      expect(game.players.first).to eq(player_3)
    end
  end

  describe 'after_starter_pack_player_order_4' do
    let(:players) { %w[a b c d] }
    let(:game) { Engine::Game::G1835::Game.new(players) }

    it 'should not move the PD if everyone passes' do
      4.times do |index|
        pass(game.players[index])
      end
      expect(game.players.first).to eq(player_1)
    end

    it 'should set the PD properly after the full sale of the starter packet' do
      buy(player_1, 'NF')
      buy(player_2, 'LD')
      pass(player_3)
      buy(player_4, '1')
      buy(player_1, '2')
      buy(player_2, 'BY_D')
      buy(player_3, '4')
      buy(player_4, '3')
      pass(player_1)
      # player_2 is skipped. Still has 101, but no current option
      buy(player_3, 'BB')
      buy(player_4, 'PB')
      buy(player_1, 'OBB')
      buy(player_2, '5')
      buy(player_3, 'HB')
      pass(player_4)
      buy(player_1, '6')

      expect(game.players.first).to eq(player_2)
    end
  end

  describe 'after_starter_pack_player_order_5' do
    let(:players) { %w[a b c d e] }
    let(:game) { Engine::Game::G1835::Game.new(players) }

    it 'should not move the PD if everyone passes' do
      5.times do |index|
        pass(game.players[index])
      end
      expect(game.players.first).to eq(player_1)
    end

    it 'should set the PD properly after the full sale of the starter packet' do
      buy(player_1, 'NF')
      buy(player_2, '1')
      buy(player_3, 'LD')
      buy(player_4, '2')
      buy(player_5, '3')
      buy(player_1, '4')
      buy(player_2, 'BY_D')
      buy(player_3, 'BB')
      buy(player_4, 'HB')
      buy(player_5, '5')
      buy(player_1, '6')
      buy(player_2, 'OBB')
      # player 3 is skipped
      # player 4 is skipped
      buy(player_5, 'PB')
      expect(game.players.first).to eq(player_1)
    end
  end

  describe 'after_starter_pack_player_order_6' do
    let(:players) { %w[a b c d e f] }
    let(:game) { Engine::Game::G1835::Game.new(players) }

    it 'should not move the PD if everyone passes' do
      6.times do |index|
        pass(game.players[index])
      end
      expect(game.players.first).to eq(player_1)
    end

    it 'should set the PD properly after the full sale of the starter packet' do
      buy(player_1, 'NF')
      buy(player_2, '1')
      buy(player_3, 'LD')
      buy(player_4, '2')
      buy(player_5, '3')
      buy(player_6, '4')
      buy(player_1, 'BY_D')
      buy(player_2, 'BB')
      buy(player_3, 'PB')
      buy(player_4, 'HB')
      buy(player_5, 'OBB')
      buy(player_6, '5')
      # player 1 is skipped
      buy(player_2, '6')
      expect(game.players.first).to eq(player_3)
    end
  end

  describe 'after_starter_pack_player_order_7' do
    let(:players) { %w[a b c d e f g] }
    let(:game) { Engine::Game::G1835::Game.new(players) }

    it 'should not move the PD if everyone passes' do
      7.times do |index|
        pass(game.players[index])
      end
      expect(game.players.first).to eq(player_1)
    end

    it 'should set the PD properly after the full sale of the starter packet' do
      buy(player_1, 'NF')
      buy(player_2, '1')
      buy(player_3, 'LD')
      buy(player_4, '2')
      buy(player_5, '3')
      buy(player_6, '4')
      buy(player_7, 'BY_D')
      buy(player_1, 'BB')
      buy(player_2, 'HB')
      buy(player_3, '5')
      buy(player_4, '6')
      buy(player_5, 'OBB')
      buy(player_6, 'PB')
      expect(game.players.first).to eq(player_7)
    end
  end

  describe 'start_packet_sale' do
    let(:players) { %w[a b c] }
    let(:game) { Engine::Game::G1835::Game.new(players) }
    let(:by) { game.corporation_by_id('BY') }
    let(:sx) { game.corporation_by_id('SX') }
    let(:ba) { game.corporation_by_id('BA') }
    let(:wt) { game.corporation_by_id('WT') }
    let(:he) { game.corporation_by_id('HE') }
    let(:pr) { game.corporation_by_id('PR') }
    let(:ms) { game.corporation_by_id('MS') }
    let(:ol) { game.corporation_by_id('OL') }

    def may_purchase?(company_id)
      game.active_step.may_purchase?(game.company_by_id(company_id))
    end

    it 'should implement the vanilla start packet draft' do
      %w[NF 1].each do |company_id|
        expect(may_purchase?(company_id)).to be true
      end
      %w[LD 2 3 4 BY_D BB HB 5 6 OBB PB].each do |company_id|
        expect(may_purchase?(company_id)).to be false
      end

      # players buy the second row
      buy(player_1, '1')
      expect(may_purchase?('LD')).to be true

      buy(player_2, 'LD')
      expect(may_purchase?('2')).to be true

      buy(player_3, '2')

      # now the first row has minor 1 and the second row is empty. The third row is still not purchasable
      %w[3 4 BY_D BB HB 5 6 OBB PB].each do |company_id|
        expect(may_purchase?(company_id)).to be false
      end

      buy(player_1, 'NF')

      # now the first and second row are empty, the entire third row becomes available
      %w[3 4 BY_D BB].each do |company_id|
        expect(may_purchase?(company_id)).to be true
      end
      %w[5 6 OBB PB].each do |company_id|
        expect(may_purchase?(company_id)).to be false
      end

      buy(player_2, '3')
      buy(player_3, '4')

      # there are still 2 companies in the third row, so the entire last row is unavailable
      %w[5 6 OBB PB].each do |company_id|
        expect(may_purchase?(company_id)).to be false
      end

      buy(player_1, 'BB')

      # only one company (BY_D) left in the third row, first company of row four must be available
      expect(may_purchase?('HB')).to be true
      %w[6 OBB PB].each do |company_id|
        expect(may_purchase?(company_id)).to be false
      end

      buy(player_2, 'HB')
      buy(player_3, '5')
      pass(player_1)
      buy(player_2, '6')
      pass(player_3)
      buy(player_1, 'OBB')
      # player_2 is out of money
      pass(player_3)
      buy(player_1, 'PB')
      # player_2 is out of money
      buy(player_3, 'BY_D')

      # START PACKET SOLD

      # player 3 bought the BY director share, but player 1 already had 30%, so player 1 must be the director
      expect(by.owner).to eq(player_1)

      expect(game.minor_by_id('1').owner).to eq(player_1)
    end
  end
end
