# frozen_string_literal: true

require 'lib/publisher'

module View
  class Welcome < Snabberb::Component
    needs :app_route, default: nil, store: true

    def render
      children = [render_hero, render_notification, render_resources]

      h('div#welcome.half', children)
    end

    def render_hero
      children = [
        h('h2.hero-title', 'Play 18xx online'),
        h('p.hero-text', 'Create a game with friends, or learn the rules with the tutorial.'),
        render_buttons,
      ]

      h('div#hero', children)
    end

    def render_notification
      message = <<~MESSAGE
        <strong>1894 is now in production.</strong>
        Report bugs and make feature requests <a href='https://github.com/tobymao/18xx/issues'>on GitHub</a>.
      MESSAGE

      props = {
        props: {
          innerHTML: message,
        },
      }

      h('div#notification', props)
    end

    def render_resources
      cards = [
        resource_card('Learn', [
          "<p><a href='https://github.com/tobymao/18xx/wiki/FAQ'>FAQ</a></p>",
          "<p><a href='https://github.com/tobymao/18xx/wiki/Power-User-Features'>Keyboard shortcuts</a></p>",
          "<p><a href='https://github.com/tobymao/18xx/wiki'>Wiki</a></p>",
        ]),
        resource_card('Community', [
          "<p>Find games in the chat or <a href='https://github.com/tobymao/18xx/wiki/18xx-Online-Communities%2C-Media%2C-and-Resources#community'>on (unofficial) Discord servers</a>.</p>",
          "<p>Ask questions in <code>#18xxgames</code> <a href='https://join.slack.com/t/18xxgames/shared_invite/zt-42uap6ff6-72R~~8khCkK08Aarwnukxw'>on the 18XX Slack</a>.</p>",
        ]),
        resource_card('Notifications', [
          "<p><a href='https://github.com/tobymao/18xx/wiki/Notifications'>Turn notifications</a> on via " \
          "<a href='https://github.com/tobymao/18xx/wiki/Notifications#discord-notifications'>Discord</a>, " \
          "<a href='https://github.com/tobymao/18xx/wiki/Notifications#slack-notifications'>Slack</a>, or " \
          "<a href='https://github.com/tobymao/18xx/wiki/Notifications#telegram-notifications'>Telegram</a>.</p>",
        ]),
        resource_card('Support the site', [
          "<p>Keep the servers running by becoming a member <a href='https://www.patreon.com/18xxgames'>on Patreon</a>.</p>",
          "<p>Buy physical copies from publishers: #{Lib::Publisher.link_list.join}.</p>",
        ]),
      ]

      h('div#resources', cards)
    end

    def resource_card(title, paragraphs)
      h('div.resource-card', {
        props: {
          innerHTML: "<h3>#{title}</h3><div class='resource-card-body'>#{paragraphs.join}</div>",
        },
      })
    end

    def render_buttons
      create_props = {
        on: {
          click: -> { store(:app_route, '/new_game') },
        },
      }

      tutorial_props = {
        on: {
          click: -> { store(:app_route, '/tutorial?action=1') },
        },
      }

      h('div#buttons', [
        h('button.primary', create_props, 'Create a new game'),
        h('button.secondary', tutorial_props, 'Tutorial'),
      ])
    end
  end
end
