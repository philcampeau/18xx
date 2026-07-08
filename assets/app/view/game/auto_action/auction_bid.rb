# frozen_string_literal: true

require 'view/game/auto_action/base'

module View
  module Game
    module AutoAction
      class AuctionBid < Base
        needs :bid_target, store: true, default: nil

        def name
          "Auto bid in Auction Round#{' (Enabled)' if @settings}"
        end

        def description
          'Automatically bid, buy or pass in the auction round.'
        end

        def render
          return [] unless @game.round.auction?

          step.respond_to?(:auto_state_for) ? render_dynamic_target : render_fixed_target
        end

        # ---------- state-aware rendering (WaterfallAuction) ----------

        def render_dynamic_target
          state, target = step.auto_state_for(@sender)

          form = {}
          children = [h(:h3, name), h(:p, description)]

          case state
          when :pre_auction
            children.concat(render_pre_auction(form))
          when :active_bidder, :future_contested
            children.concat(render_current_auction(form, target))
          when :face_value
            children.concat(render_face_value(form, target))
          else
            children << h(:p, 'No auto actions available right now.')
            return children
          end

          subchildren = [render_button(@settings ? 'Update' : 'Enable') { enable_fixed_target(form, state, target) }]
          subchildren << render_disable(@settings) if @settings
          children << h(:div, subchildren)

          children
        end

        def render_pre_auction(form)
          bid_target_change = lambda do
            target = Native(form[:bid_target]).elm&.value
            bid_target = @game.corporation_by_id(target) || @game.company_by_id(target) || @game.minor_by_id(target)
            store(:bid_target, bid_target)
          end

          target = selected
          children = [h(:div, [render_input('Bid Target',
                                            id: 'bid_target',
                                            el: 'select',
                                            on: { input: bid_target_change },
                                            children: values, inputs: form)])]

          children << h(Corporation, corporation: target) if target&.corporation? || target&.minor?
          children << h(Company, company: target) if target&.company?

          children << h(:div, [render_enable_place_bid(form, target), render_place_bid(form, target)])
          children
        end

        def buyable_now?(target)
          step.respond_to?(:may_purchase?) && target && step.may_purchase?(target)
        end

        def render_enable_place_bid(form, target)
          checked = @settings&.enable_place_bid || false
          label = buyable_now?(target) ? 'Buy for' : 'Place a bid up to'

          render_input(label,
                       id: 'enable_place_bid',
                       type: 'checkbox',
                       inputs: form,
                       attrs: { checked: checked })
        end

        def render_place_bid(form, target)
          if buyable_now?(target)
            value = target.min_bid
            render_input('',
                         id: 'place_bid',
                         type: 'number',
                         inputs: form,
                         attrs: { value: value, disabled: true })
          else
            value = @settings&.place_bid || step&.min_bid(target)
            render_input('',
                         id: 'place_bid',
                         type: 'number',
                         inputs: form,
                         attrs: {
                           value: value,
                           step: step.min_increment,
                           min: target ? target.min_bid : 0,
                         })
          end
        end

        def render_current_auction(form, target)
          children = []
          children << h(Corporation, corporation: target) if target.corporation? || target.minor?
          children << h(Company, company: target) if target.company?

          children << h(:div, [render_enable_maximum_bid(form), render_maximum_bid(form, target)])
          children << h(:div, [render_unconditional_pass(form)])
          children << h(:div, [render_auto_pass(form)])
          children
        end

        def render_face_value(form, target)
          children = []
          children << h(Corporation, corporation: target) if target.corporation? || target.minor?
          children << h(Company, company: target) if target.company?
          children << h(:p, "#{target.name} currently has no bids — buy at face value or pass.")

          children << h(:div, [render_auto_buy_face_value(form)])
          children << h(:div, [render_unconditional_pass(form)])
          children
        end

        def render_enable_maximum_bid(form)
          checked = @settings ? !!@settings.enable_maximum_bid : false

          render_input('Maximum Bid',
                       id: 'enable_maximum_bid',
                       type: 'checkbox',
                       name: 'mode',
                       inputs: form,
                       attrs: { name: 'mode_options', checked: checked })
        end

        def render_maximum_bid(form, target)
          value = @settings&.maximum_bid || step.min_bid(target)
          render_input('',
                       id: 'maximum_bid',
                       type: 'number',
                       inputs: form,
                       attrs: {
                         value: value,
                         step: step.min_increment,
                         min: step.min_bid(target),
                       })
        end

        def render_unconditional_pass(form)
          checked = @settings ? !!@settings.unconditional_pass : false

          render_input('Pass',
                       id: 'unconditional_pass',
                       type: 'checkbox',
                       name: 'mode',
                       inputs: form,
                       attrs: { name: 'mode_options', checked: checked })
        end

        def render_auto_buy_face_value(form)
          checked = @settings ? !!@settings.auto_buy_face_value : false

          render_input('Buy at face value',
                       id: 'auto_buy_face_value',
                       type: 'checkbox',
                       name: 'mode',
                       inputs: form,
                       attrs: { name: 'mode_options', checked: checked })
        end

        def render_auto_pass(form)
          checked = selected == @settings&.bid_target ? !!@settings&.auto_pass_after : false

          render_checkbox('Pass after max bid reached / buy price impossible  ',
                          'auto_pass_after',
                          form,
                          checked)
        end

        def enable_fixed_target(form, state, target)
          @settings = params(form)

          checked = case state
                    when :pre_auction
                      @settings['enable_place_bid']
                    when :active_bidder, :future_contested
                      @settings['enable_maximum_bid'] || @settings['unconditional_pass']
                    when :face_value
                      @settings['auto_buy_face_value'] || @settings['unconditional_pass']
                    end
          return unless checked

          bid_target = state == :pre_auction ? selected : target

          process_action(
            Engine::Action::ProgramAuctionBid.new(
              @sender,
              bid_target: bid_target,
              place_bid: @settings['place_bid'] || (buyable_now?(bid_target) ? bid_target.min_bid : nil),
              enable_place_bid: @settings['enable_place_bid'],
              maximum_bid: @settings['maximum_bid'],
              enable_maximum_bid: @settings['enable_maximum_bid'],
              unconditional_pass: @settings['unconditional_pass'],
              auto_buy_face_value: @settings['auto_buy_face_value'],
              auto_pass_after: @settings['auto_pass_after'],
            )
          )
        end

        # ---------- ModifiedDutchAuction rendering (18EU currently) ----------

        def render_fixed_target
          form = {}

          children = [h(:h3, name), h(:p, description), h(:div, [render_entity_selector(form)])]

          children << h(Corporation, corporation: selected) if selected&.corporation? || selected&.minor?
          children << h(Company, company: selected) if selected&.company?

          children << h(:div, [render_enable_maximum_bid_legacy(form), render_maximum_bid_fixed(form)])
          children << h(:div, [render_enable_buy_price(form), render_buy_price(form)])
          children << h(:div, [render_auto_pass(form)])

          subchildren = [render_button(@settings ? 'Update' : 'Enable') { enable_dynamic_target(form) }]
          subchildren << render_disable(@settings) if @settings
          children << h(:div, subchildren)

          children
        end

        def render_entity_selector(form)
          bid_target_change = lambda do
            target = Native(form[:bid_target]).elm&.value
            bid_target = @game.corporation_by_id(target) || @game.company_by_id(target) || @game.minor_by_id(target)
            store(:bid_target, bid_target)
          end

          render_input('Bid Target',
                       id: 'bid_target',
                       el: 'select',
                       on: { input: bid_target_change },
                       children: values, inputs: form)
        end

        def render_enable_maximum_bid_legacy(form)
          checked = selected == @settings&.bid_target ? !!@settings&.enable_maximum_bid : false

          render_input('Maximum Bid',
                       id: 'enable_maximum_bid',
                       type: 'checkbox',
                       name: 'mode',
                       inputs: form,
                       attrs: { name: 'mode_options', checked: checked })
        end

        def render_maximum_bid_fixed(form)
          value = selected == @settings&.bid_target ? @settings&.maximum_bid : step.min_bid(selected)
          render_input('',
                       id: 'maximum_bid',
                       type: 'number',
                       inputs: form,
                       attrs: {
                         value: value,
                         step: step.min_increment,
                         min: step.min_bid(selected),
                       })
        end

        def render_enable_buy_price(form)
          checked = selected == @settings&.bid_target ? !!@settings&.enable_buy_price : false

          render_input('Buy Price',
                       id: 'enable_buy_price',
                       type: 'checkbox',
                       name: 'mode',
                       inputs: form,
                       attrs: { name: 'mode_options', checked: checked })
        end

        def render_buy_price(form)
          value = selected == @settings&.bid_target ? @settings&.buy_price : 0

          render_input('', id: 'buy_price', type: 'number', inputs: form,
                           attrs: { value: value, step: step.min_increment, min: 0 })
        end

        def enable_dynamic_target(form)
          @settings = params(form)

          bid_target = @game.corporation_by_id(@settings['bid_target']) ||
                        @game.company_by_id(@settings['bid_target']) ||
                        @game.minor_by_id(@settings['bid_target'])

          checked = @settings['enable_buy_price'] || @settings['enable_maximum_bid'] || @settings['auto_pass_after']
          return unless checked

          process_action(
            Engine::Action::ProgramAuctionBid.new(
              @sender,
              bid_target: bid_target,
              enable_maximum_bid: @settings['enable_maximum_bid'],
              maximum_bid: @settings['maximum_bid'],
              enable_buy_price: @settings['enable_buy_price'],
              buy_price: @settings['buy_price'] || 0,
              auto_pass_after: @settings['auto_pass_after'],
            )
          )
        end

        # ---------- shared helpers ----------

        def available_targets
          step.available
        end

        def step
          @game.round.active_step
        end

        def selected
          @bid_target || @settings&.bid_target || available_targets.first
        end

        def values
          available_targets.map do |entity|
            attrs = { value: entity.id }
            attrs[:selected] = true if selected == entity
            h(:option, { attrs: attrs }, entity.name)
          end
        end
      end
    end
  end
end
