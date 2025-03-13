# frozen_string_literal: true

require_relative '../../../step/train'

module Engine
  module Game
    module G1856
      module Train
        include Engine::Step::Train

        LAST_TRAINS = %w[2-5 3-4 4-3 5-2].freeze

        def buy_train_action(action, entity = nil, borrow_from: nil)
          @game.change_float if action.train.owner == @game.depot && LAST_TRAINS.include?(action.train.id)

          super
        end
      end
    end
  end
end
