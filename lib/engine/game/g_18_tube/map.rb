# frozen_string_literal: true

module Engine
  module Game
    module G18Tube
      module Map
        TILES = {
          # '3' => 'unlimited',
          # '4' => 'unlimited',
          # '5' => 6,
          # '6' => 6,
          # '7' => 'unlimited',
          # '8' => 'unlimited',
          # '9' => 'unlimited',
          # '14' => 4,
          # '15' => 4,
          # '16' => 1,
          # '17' => 1,
          # '18' => 1,
          # '19' => 1,
          # '20' => 1,
          # '21' => 1,
          # '22' => 1,
          # '57' => 6,
          # '58' => 'unlimited',
          # '63' => 4,
          # '87' => 3,
          # '88' => 3,
          # '204' => 3,
          # '207' => 1,
          # '208' => 1,
          # '455' => 2,
          # '611' => 2,
          # '619' => 4,
          # '621' => 1,
          # '622' => 1,
          # '625' => 1,
          # '626' => 1,
          # '776' => 1,
          # '911' => 3,
          # '8858a' => 1,
          # '8860' => 1,
          # '8862' => 1,
          # 'x7d' => 1,
          # 'x9b' => 1,
        }.freeze

        LOCATION_NAMES = {
          'A16' => 'Edgeware',
          'A18' => 'Mornington Crescent',
          'A24' => 'Finsbury Park',
          'B19' => 'Euston',
          'B23' => 'King\'s Cross',
          'C6' => 'Watford',
          'C8' => 'St. John\'s Wood',
          'C10' => 'Baker Street',
          'C18' => 'Goodge street',
          'C26' => 'Angel',
          'D5' => 'Paddington',
          'D23' => 'Bloomsbury',
          'D25' => 'Farringdon',
          'E20' => 'Tottenham Court Road',
          'E30' => 'Moorgate',
          'E32' => 'Liverpool Street',
          'E40' => 'Upminster',
          'F1' => 'Ealing',
          'F9' => 'Marble Arch',
          'F29' => 'Bank',
          'F33' => 'Aldgate',
          'F37' => 'Whitechapel',
          'G18' => 'Piccadilly Circus',
          'G26' => 'Blackfriars',
          'G28' => 'Mansion House',
          'G30' => 'Canon Street',
          'G32' => 'Edgeware',
          'H21' => 'Charing Cross',
          'I2' => 'Kensington',
          'I32' => 'London Bridge',
          'J25' => 'Waterloo',
          'K2' => 'Hammersmith',
          'K14' => 'Victoria',
          'K20' => 'Westminster',
          'L29' => 'Elephant & Castle',
          'M4' => 'Putney Bridge',
          'M24' => 'Kennigton',
          'O22' => 'Stockwell Street',
          'P3' => 'Wimbledon',
          'P17' => 'Clapham',
        }.freeze

        HEXES = {
          red: {
            %w[A16 C6] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_50;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            %w[O22 P17] => 'offboard=revenue:yellow_30|green_40|brown_60|gray_80;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0'\
                           ';path=a:4,b:_0',
            ['A24'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_50;path=a:0,b:_0;path=a:5,b:_0',
            ['E40'] => 'offboard=revenue:yellow_30|green_40|brown_60|gray_80;path=a:0,b:_0;path=a:1,b:_0',
            ['F1'] => 'offboard=revenue:yellow_20|green_50|brown_80|gray_100;path=a:4,b:_0;path=a:5,b:_0',
            ['K2'] => 'offboard=revenue:yellow_20|green_50|brown_80|gray_100;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['P3'] => 'offboard=revenue:yellow_20|green_50|brown_80|gray_100;path=a:3,b:_0;path=a:4,b:_0',
          },
          white: {
            %w[
              A20
              A22
              B15
              B17
              B21
              B25
              C8
              C12
              C14
              C16
              C20
              C22
              C24
              C28
              D7
              D9
              D11
              D13
              D15
              D17
              D19
              D21
              D31
              E4
              E6
              E8
              E10
              E12
              E14
              E16
              E18
              E22
              E34
              E36
              E38
              F7
              F11
              F13
              F15
              F17
              F19
              F21
              F23
              F35
              F39
              G2
              G12
              G14
              G16
              G20
              G22
              G24
              G34
              G36
              G38
              H3
              H13
              H15
              H17
              H19
              H23
              H35
              H37
              I4
              I6
              I8
              I10
              I12
              I18
              I20
              I22
              I26
              I28
              I30
              J3
              J5
              J7
              J9
              J11
              J13
              J21
              J27
              J29
              J31
              J33
              J35
              J37
              K8
              K10
              K12
              K18
              K24
              K26
              K28
              K30
              L3
              L5
              L7
              L9
              L11
              L13
              L15
              L17
              L19
              L23
              L25
              L27
              M6
              M8
              M10
              M22
              N13
              N15
              N17
              N19
              N21
              N23
              N25
              O4
              O6
              O8
              O10
              O12
              O14
              O18
              O20
              O24
              P5
              P7
              P9
              P11
              P13
              P15
              P19
            ] => '',
            %w[A18 C10 C18 E20 F9 F37 G18 I2 K20 M4] => 'town=revenue:0',
            %w[B19 D5 H21 I32 J25] => 'city=revenue:0',
            # terrain on next line is a placeholder for parks
            %w[A14 B11 B13 G4 G6 G8 G10 H5 H7 H9 H11 I14 I16 J15 J17 J19 O16] => 'upgrade=cost:0,terrain:swamp',
            %w[
              H25 H27 H29 H31 H33 H39 I24 I34 I36 I38 J23 K22 L21 M12 M14 M16 M18 M20 N3 N5 N7 N9 N11
            ] => 'upgrade=cost:20,terrain:water',
            %w[D27 D29 E24 E26 E28 F25 F27 F31] => 'upgrade=cost:40,terrain:mountain',
            %w[C26 D23 E30 F29 F33 G26 G28 G32] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[D25 E32 G30] => 'city=revenue:0;upgrade=cost:40,terrain:mountain',
          },
          yellow: {
            %w[F3 F5 K4 K6 K16 M26] => 'path=a:1,b:4',
            ['B23'] => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:3,b:_1;label=OO',
            ['K14'] => 'city=revenue:30;path=a:1,b:_0;path=a:4,b:_0;label=Y',
            ['L29'] => 'town=revenue:10;path=a:0,b:_0',
            ['M24'] => 'town=revenue:10;path=a:4,b:_0',
            ['M28'] => 'path=a:1,b:3',
          },
        }.freeze

        LAYOUT = :pointy
      end
    end
  end
end
