# frozen_string_literal: true

module Engine
  module Game
    module G18GB
      module Entities
        COMPANIES = [
          {
            name: 'London & Birmingham',
            value: 40,
            revenue: 10,
            desc: "The owner of the L&B has priority for starting the LNWR. No other player may buy the Director's " \
                  'Certificate of the LNWR, and the owner of the London & Birmingham may not buy shares in any other company' \
                  "until they have purchased the LNWR Director's Certificate.",
            sym: 'LB',
            color: nil,
            open_abilities: [
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: ['F21'],
              },
            ],
          },
          {
            name: 'Arbroath & Forfar',
            value: 30,
            revenue: 10,
            desc: 'The Arbroath & Forfar allows a company to take an extra tile lay action to lay or upgrade a tile in Perth ' \
                  '(I2). The owner of the AF may use this ability once per game, after the AF has closed, for any company ' \
                  'which they control. A tile placed in Perth as a nomral tile lay does not close the AF.',
            sym: 'AF',
            color: nil,
            open_abilities: [
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: ['K2']
              }
            ],
          },
          {
            name: 'Great Northern',
            value: 70,
            revenue: 25,
            desc: 'The GN allows a company to lay a free Station Marker in York (I14). The GN owner may use this ability once ' \
                  'per game, after the GN has closed, for any company which they control.',
            sym: 'GN',
            color: nil,
            open_abilities: [
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: ['I18']
              }
            ],
          },
          {
            name: 'Stockton & Darlington',
            value: 45,
            revenue: 15,
            desc: 'The SD gives a bonus of £10 for Middlesbrough (J13). The owner of the SD may use this bonus for any trains ' \
                  'owned by Companies that they control, from the time that the LM closes until the end of the game.',
            sym: 'SD',
            color: nil,
            open_abilities: [
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: ['I12']
              }
            ],
          },
          {
            name: 'Liverpool & Manchester',
            value: 45,
            revenue: 15,
            desc: 'The LM gives a bonus of £10 for Liverpool (E14). The owner of the LM may use this bonus for any trains run ' \
                  'by Companies that they control, from the time that the LM closes until the end of the game.',
            sym: 'LM',
            color: nil,
            open_abilities: [
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: ['F15']
              }
            ],
          },
          {
            name: 'Leicester & Swannington',
            value: 30,
            revenue: 10,
            desc: 'The LS allows a company to take an extra tile lay action to lay or upgrade a tile in Leicester (H21). The ' \
                  'owner of the LS may use this ability once per game, after the LS has closed, for any company which they ' \
                  'control.',
            sym: 'LS',
            color: nil,
            open_abilities: [
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: ['H21']
              }
            ],
          },
          {
            name: 'Taff Vale',
            value: 60,
            revenue: 20,
            desc: 'The TV allows a company to waive the cost of laying the Severn Tunnel tile - the blue estuary tile marked ' \
                  '"S" - in hex C22. This follows the usual rules for upgrades, so the game must be in an appropriate phase, ' \
                  'some part of the new track on the new tile must form part of a route for the company, and the company must ' \
                  'not be Insolvent. The owner of the TV may use this ability after the TV has closed, for any company which ' \
                  'they control. If a company places the Severn Tunnel tile without using the ability of the TV, this does not ' \
                  'force the TV to close.',
            sym: 'TV',
            color: nil,
            open_abilities: [
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: ['C20']
              }
            ],
          },
          {
            name: 'Maryport & Carlisle',
            value: 60,
            revenue: 20,
            desc: 'The MC allows a company to lay a Station Marker in Carlisle (H9). The MC owner may use this ability once ' \
                  'per game, after the MC has closed, for any company which they control.',
            sym: 'MC',
            color: nil,
            open_abilities: [
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: ['G10']
              }
            ],
          },
          {
            name: 'Chester & Holyhead',
            value: 30,
            revenue: 10,
            desc: 'The CH gives a bonus income of £20 for Holyhead (C14). The owner of the CH may use this bonus for any ' \
                  'trains run by Companies that they control, from the time that the CH closes until the end of the game.',
            sym: 'CH',
            color: nil,
            open_abilities: [
              {
                type: 'blocks_hexes',
                owner_type: 'player',
                hexes: ['E16']
              }
            ],
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'CR',
            name: 'Caledonian Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/CR',
            shares: [40, 20, 20, 20],
            tokens: [0, 0],
            coordinates: 'G4',
            color: '#0a70b3',
            reservation_color: nil,
            always_market_price: true,
          },
          {
            sym: 'GER',
            name: 'Great Eastern Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/GER',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'J25',
            color: '#37b2e2',
            reservation_color: nil,
            always_market_price: true,
          },
          {
            sym: 'GSWR',
            name: 'Glasgow and South Western Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/GSWR',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'F5',
            color: '#ec767c',
            reservation_color: nil,
            always_market_price: true,
          },
          {
            sym: 'GWR',
            name: 'Great Western Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/GWR',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'D23',
            color: '#008f4f',
            reservation_color: nil,
            always_market_price: true,
          },
          {
            sym: 'LNWR',
            name: 'London and North Western Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/LNWR',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'F21',
            color: '#0a0a0a',
            text_color: '#ffffff',
            reservation_color: nil,
            always_market_price: true,
          },
          {
            sym: 'LSWR',
            name: 'London and South Western Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/LSWR',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'D25',
            color: '#fcea18',
            reservation_color: nil,
            always_market_price: true,
          },
          {
            sym: 'LYR',
            name: 'Lancashire and Yorkshire Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/LYR',
            shares: [40, 20, 20, 20],
            tokens: [0],
            coordinates: 'H15',
            color: '#baa4cb',
            reservation_color: nil,
            always_market_price: true,
          },
          {
            sym: 'MR',
            name: 'Midland Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/MR',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'H19',
            color: '#dd0030',
            reservation_color: nil,
            always_market_price: true,
          },
          {
            sym: 'MSLR',
            name: 'Manchester, Sheffield and Lincolnshire Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/MSLR',
            shares: [40, 20, 20, 20],
            tokens: [0],
            coordinates: 'H17',
            color: '#881a1e',
            reservation_color: nil,
            always_market_price: true,
          },
          {
            sym: 'NBR',
            name: 'North British Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/NBR',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'I6',
            color: '#eb6f0e',
            reservation_color: nil,
            always_market_price: true,
          },
          {
            sym: 'NER',
            name: 'North Eastern Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/NER',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'J13',
            color: '#7bb137',
            reservation_color: nil,
            always_market_price: true,
          },
          {
            sym: 'SWR',
            name: 'South Wales Railway',
            type: '5-share',
            float_percent: 40,
            logo: '18_gb/SWR',
            shares: [40, 20, 20, 20],
            tokens: [0, 50],
            coordinates: 'A20',
            color: '#9a9a9d',
            reservation_color: nil,
            always_market_price: true,
          },
      ].freeze
      end
    end
  end
end
