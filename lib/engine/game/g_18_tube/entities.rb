# frozen_string_literal: true

module Engine
  module Game
    module G18Tube
      module Entities
        COMPANIES = [
          {
            name: "St. John's Wood Railway",
            sym: 'P1',
            value: 20,
            revenue: 5,
            desc: 'The owning corporation may place a tile in C3, without paying terrain costs, in addition to its normal tile '\
                  'placement. The corp doesn’t need to have a route to the hex. Blocks C3 until used or closed. '\
                  'Closes in phase 5.',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['C3'] }],
            color: nil,
          },
          {
            name: 'Great Northern Railway',
            sym: 'P2',
            value: 30,
            revenue: 5,
            desc: 'The owning corporation adds £10 to each run that counts Finsbury Park (A24) in its route. Closes in phase 5.',
            color: nil,
          },
          {
            name: 'John Fowler Engineering',
            sym: 'P3',
            value: 40,
            revenue: 10,
            desc: 'The owning corporation may build on river hexes for free. Closes in phase 5.',
            color: nil,
          },
          {
            name: 'Charles Pearson',
            sym: 'P4',
            value: 110,
            revenue: 20,
            desc: 'Allows the owning corporation to run one of its trains to the same station twice if the route forms a loop. '\
                  'The corporation must follow all other normal rules for track and train connections. Does not close.',
            color: nil,
          },
          {
            name: 'Deel Level Tunnels',
            sym: 'P5',
            value: 60,
            revenue: 10,
            desc: '',
            color: nil,
          },
          {
            name: 'Charles Yerkes',
            sym: 'BO',
            value: 220,
            revenue: 30,
            desc: '',
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'PRR',
            name: 'Pennsylvania Railroad',
            logo: '18_chesapeake/PRR',
            simple_logo: '1830/PRR.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'H12',
            color: '#32763f',
          },
          {
            float_percent: 60,
            sym: 'NYC',
            name: 'New York Central Railroad',
            logo: '1830/NYC',
            simple_logo: '1830/NYC.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'E19',
            color: :'#474548',
          },
          {
            float_percent: 60,
            sym: 'CPR',
            name: 'Canadian Pacific Railroad',
            logo: '1830/CPR',
            simple_logo: '1830/CPR.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'A19',
            color: '#d1232a',
          },
          {
            float_percent: 60,
            sym: 'B&O',
            name: 'Baltimore & Ohio Railroad',
            logo: '18_chesapeake/BO',
            simple_logo: '1830/BO.alt',
            tokens: [0, 40, 100],
            coordinates: 'I15',
            color: '#025aaa',
          },
          {
            float_percent: 60,
            sym: 'C&O',
            name: 'Chesapeake & Ohio Railroad',
            logo: '18_chesapeake/CO',
            simple_logo: '1830/CO.alt',
            tokens: [0, 40, 100],
            coordinates: 'F6',
            color: :'#ADD8E6',
            text_color: 'black',
          },
          {
            float_percent: 60,
            sym: 'ERIE',
            name: 'Erie Railroad',
            logo: '1846/ERIE',
            simple_logo: '1830/ERIE.alt',
            tokens: [0, 40, 100],
            coordinates: 'E11',
            color: :'#FFF500',
            text_color: 'black',
          },
          {
            float_percent: 60,
            sym: 'NYNH',
            name: 'New York, New Haven & Hartford Railroad',
            logo: '1830/NYNH',
            simple_logo: '1830/NYNH.alt',
            tokens: [0, 40],
            coordinates: 'G19',
            city: 0,
            color: :'#d88e39',
          },
          {
            float_percent: 60,
            sym: 'B&M',
            name: 'Boston & Maine Railroad',
            logo: '1830/BM',
            simple_logo: '1830/BM.alt',
            tokens: [0, 40],
            coordinates: 'E23',
            color: :'#95c054',
          },
        ].freeze
      end
    end
  end
end
