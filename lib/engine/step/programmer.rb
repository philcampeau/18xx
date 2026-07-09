# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    module Programmer
      def programmed_auto_actions(entity)
        warn "programmed_auto_actions called for #{entity.name}, programs=#{@game.programmed_actions[entity.player].map(&:to_h)}"
        return if (p_list = @game.programmed_actions[entity.player]).empty?

        a_list = []
        p_list.each do |program|
          method = "activate_#{program.type}"
          warn "checking method=#{method} respond_to=#{respond_to?(method)}"
          next unless respond_to?(method, true)

          new_actions = send(method, entity, program)
          warn "activate result=#{new_actions.inspect}"
          a_list.concat(new_actions) if new_actions
        end
        a_list
      end
    end
  end
end
