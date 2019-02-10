module Correios
  module SRO
    class Helper
      def namespaces
        {
          'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
          'xmlns:ns1' => 'http://resource.webservice.correios.com.br/'
        }
      end

      def tracking_event_status(event)
        type = event[:tipo]
        status = event[:status].to_i

        case type
        when 'BDE', 'BDI', 'BDR'
          case status
          when 0, 1
            return :delivered
          when 2
            return :not_delivered
          when 4, 5, 6, 8, 10, 21, 22, 26, 33, 36, 40, 42, 48, 49, 56
            return :returning
          when 7, 19, 25, 32, 38, 41, 45, 46, 47, 53, 57, 66, 69
            return :in_transit
          when 9, 50, 51, 52
            return :stolen_lost
          when 3, 12, 24
            return :awaiting_pick_up
          when 20, 34, 35
            return :not_delivered
          when 23
            return :returned
          when 28, 37
            return :damaged
          when 43
            return :arrested
          when 54, 55, 58, 59
            return :taxing
          end
        when 'BLQ', 'PMT', 'CD', 'CMT', 'TRI', 'CUN', 'RO', 'DO', 'EST', 'PAR'
          case status
          when 0, 1, 2, 3, 4, 5, 6, 9, 15, 16, 17, 18
            return :in_transit
          end
        when 'FC'
          case status
          when 1
            return :returning
          when 2, 3, 5, 7
            return :in_transit
          when 4
            return :not_delivered
          end
        when 'IDC'
          case status
          when 1, 2, 3, 4, 5, 6, 7
            return :stolen_lost
          end
        when 'LDI'
          case status
          when 0, 1, 2, 3, 14
            return :awaiting_pick_up
          end
        when 'OEC', 'LDE'
          case status
          when 0, 1, 9
            return :delivering
          end
        when 'PO', 'CO'
          case status
          when 0, 1, 9
            return :posted
          end
        end
      end

      def query_type(type)
        case type
        when :list
          'L'
        when :range
          'F'
        end
      end

      def result_type(type)
        case type
        when :last_event
          'U'
        when :all_events
          'T'
        end
      end

      def language(type)
        case type
        when :portuguese
          '101'
        when :english
          '102'
        end
      end

      def format_label_numbers(label_numbers)
        label_numbers_string = ''
        label_numbers.each do |label_number|
          label_numbers_string += label_number
        end
        label_numbers_string
      end

      def convert_string_to_date(date, time)
        Time.strptime("#{date} #{time}", '%d/%m/%Y %H:%M')
      end
    end
  end
end
