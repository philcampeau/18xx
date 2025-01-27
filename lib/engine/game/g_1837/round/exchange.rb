# frozen_string_literal: true

require_relative '../../../round/choices'

module Engine
  module Game
    module G1837
      module Round
        class Exchange < Engine::Round::Choices
          def name
            'Exchange Round'
          end

          def self.short_name
            'ER'
          end

          def select_entities
            @game.exchange_order
          end

          def setup
            super
            skip_steps
            next_entity! if finished?
          end

          def after_process(_action)
            return if active_step

            next_entity!
          end

          def next_entity!
            next_entity_index! unless @entities.empty?
            return if @entity_index.zero?

            @steps.each(&:unpass!)
            @steps.each(&:setup)

            skip_steps
            next_entity! if finished?
          end
        end
      end
    end
  end
end
