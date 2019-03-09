require_relative './exception'

require 'date'
require 'time'

class Helper < CorreiosException
  def generate_soap_fault_exception(message)
    message = message.to_s.gsub('(soap:Server)', '')
    message = message.strip
    generate_exception(message.capitalize)
  end

  def generate_http_exception(status)
    case status
    when 400
      generate_exception("Bad request. Status code #{status}")
    when 401
      generate_exception("Access unauthorized. Status code #{status}")
    when 404
      generate_exception("Data or method not found. Status code #{status}")
    when 500
      generate_exception("Internal server error. Status code #{status}")
    when 503
      generate_exception("Service unavailable. Status code #{status}")
    when 504
      generate_exception("Gateway timeout. Status code #{status}")
    else
      generate_exception("Unknown HTTP error. Status code #{status}")
    end
  end

  def generate_revese_logistics_exception(response)
    unless response[:cod_erro].to_i.zero?
      generate_exception(response[:msg_erro].capitalize)
    end
  end

  def generate_sro_exception(objects)
    generate_exception(objects.first[:erro]) if objects.first[:numero] == 'Erro'
  end

  def remove_label_digit_checker(label_number)
    label_number.slice!(10)
    label_number
  end

  def calculate_reverse_shipping_deadline(value, type)
    if type == :authorization
      return value if value.is_a?(Numeric)

      Date.today - value
    else
      return (Date.today + value).strftime('%d/%m/%Y') if value.is_a?(Numeric)

      value.strftime('%d/%m/%Y')
    end
  end

  def calculate_shipping_deadline(days, saturday, date = Date.today)
    if saturday
      days.to_i.times do
        date += 1.days
        date += 1.days if date.sunday?
      end
    else
      days.to_i.times do
        date += 1.days
        date += 1.days if deadline.sunday? || deadline.saturday?
      end
    end
    date
  end

  # Converters

  def string_to_bool(string)
    string.strip == 'S'
  end

  def bool_to_string(bool)
    bool ? 'S' : 'N'
  end

  def bool_to_int(bool)
    bool ? 1 : 0
  end

  def string_to_time(date, time)
    time = time.strftime('%H:%M:%S')
    Time.strptime("#{date} #{time}", '%d-%m-%Y %H:%M:%S')
  end

  def string_to_time_no_second(date, time)
    Time.strptime("#{date} #{time}", '%d/%m/%Y %H:%M')
  end

  def string_to_date(date)
    Date.strptime(date, '%d/%m/%Y')
  end

  def date_to_string(date)
    date.strftime('%d/%m/%Y')
  end

  def string_to_decimal(string)
    return nil if string.nil?

    string.tr(',', '.').to_f
  end

  def decimal_to_string(decimal)
    return nil if decimal.nil?

    decimal.to_s.tr('.', ',')
  end

  def array_to_string_comma(array)
    return nil if array.nil?

    array.join(',')
  end

  def array_to_string(array)
    return nil if array.nil?

    array.join('')
  end

  # Enumerizers

  def object_type(type)
    case type
    when :letter_envelope
      '001'
    when :box
      '002'
    when :prism
      '002'
    when :cylinder
      '003'
    else
      generate_exception('Object type not in list.')
    end
  end

  def pricefier_object_type(type)
    case type
    when :letter_envelope
      3
    when :box
      1
    when :prism
      1
    when :cylinder
      2
    else
      generate_exception('Object type not in list.')
    end
  end

  def payment_method(method)
    case method
    when :postal_vouncher
      1
    when :postal_refound
      2
    when :exchange_contract
      3
    when :credit_card
      4
    when :other
      5
    when :to_bill
      nil
    else
      generate_exception('Payment method not in list.')
    end
  end

  def reverse_shipping_type(type)
    case type
    when :authorization
      'A'
    when :pickup
      'C'
    when :authorization_pickup
      'CA'
    else
      generate_exception('Shipping type not in list.')
    end
  end

  def ticket_type(type)
    case type
    when :authorization
      'AP'
    when :pickup
      'LR'
    else
      generate_exception('Tickect type not in list.')
    end
  end

  def reverse_shipping_service(service)
    case service
    when :pac
      'LR'
    when :sedex
      'LS'
    when :e_sedex
      'LV'
    else
      service
    end
  end

  def reverse_tracking_result_type(result_type)
    case result_type
    when :last_event
      'U'
    when :all_events
      'H'
    else
      generate_exception('Tracking result type not in list.')
    end
  end

  def tracking_query_type(query_type)
    case query_type
    when :list
      'L'
    when :range
      'F'
    else
      generate_exception('Query type not in list.')
    end
  end

  def tracking_result_type(result_type)
    case result_type
    when :last_event
      'U'
    when :all_events
      'T'
    else
      generate_exception('Query type not in list.')
    end
  end

  def tracking_language(language)
    case language
    when :portuguese
      '101'
    when :english
      '102'
    else
      generate_exception('Language not in list.')
    end
  end

  # Inverted enumerizers

  def inverse_card_status(status)
    case status
    when 'Normal'
      :ok
    when 'Cancelado'
      :canceled
    end
  end

  def inverse_shipping_cancellation(status)
    case status
    when 'Registro gravado'
      :ok
    end
  end

  def inverse_payment_method(method)
    case method
    when '1'
      :postal_vouncher
    when '2'
      :postal_refound
    when '3'
      :exchange_contract
    when '4'
      :credit_card
    when '5'
      :other
    when nil
      :to_bill
    end
  end

  def inverse_object_type(type)
    case type
    when '1'
      :letter_envelope
    when '2'
      :box_prism
    when '3'
      :cylinder
    end
  end

  def inverse_service_availability(availability)
    case availability.to_i
    when 0, 11
      :available
    when -2, -3
      :invalid_zip_code
    when -33
      :system_down
    when -34, -35, 1
      :incorrect_data
    when -36, -37, -38
      :unauthorized
    when -888, 6, 7, 8, 9, 12
      :unavailable
    when 10
      :partially_available
    when 99
      :error
    end
  end

  def inverse_reverse_shipping_type(type)
    case type
    when 'A'
      :authorization
    when 'C'
      :pickup
    end
  end

  def inverse_tracking_event_status(event)
    type = event['tipo'] || event[:tipo]
    status = event['status'] || event[:status]
    status = status.to_i

    case type
    when 'BDE', 'BDI', 'BDR'
      case status
      when 0, 1
        :delivered
      when 2
        :not_delivered
      when 4, 5, 6, 8, 10, 21, 22, 26, 33, 36, 40, 42, 48, 49, 56
        :returning
      when 7, 19, 25, 32, 38, 41, 45, 46, 47, 53, 57, 66, 69
        :in_transit
      when 9, 50, 51, 52
        :stolen_lost
      when 3, 12, 24
        :awaiting_pick_up
      when 20, 34, 35
        :not_delivered
      when 23
        :returned
      when 28, 37
        :damaged
      when 43
        :arrested
      when 54, 55, 58, 59
        :taxing
      end
    when 'BLQ', 'PMT', 'CD', 'CMT', 'TRI', 'CUN', 'RO', 'DO', 'EST', 'PAR'
      case status
      when 0, 1, 2, 3, 4, 5, 6, 9, 15, 16, 17, 18
        :in_transit
      end
    when 'FC'
      case status
      when 1
        :returning
      when 2, 3, 5, 7
        :in_transit
      when 4
        :not_delivered
      end
    when 'IDC'
      case status
      when 1, 2, 3, 4, 5, 6, 7
        :stolen_lost
      end
    when 'LDI'
      case status
      when 0, 1, 2, 3, 14
        :awaiting_pick_up
      end
    when 'OEC', 'LDE'
      case status
      when 0, 1, 9
        :delivering
      end
    when 'PO', 'CO'
      case status
      when 0, 1, 9
        :posted
      end
    end
  end
end
