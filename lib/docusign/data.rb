module Docusign
  class Data

    def initialize(data={})
      @data = data
    end

    private

      def method_missing(name, *args, &block)
        if name.to_s =~ /^(\w*)$/ && @data.has_key?($1.to_sym)
          if @data[$1.to_sym].is_a?(Hash)
            self.class.new(@data[$1.to_sym])
          elsif @data[$1.to_sym].is_a?(Array)
            to_data_array(@data[$1.to_sym])
          else
            to_parsed_data(@data[$1.to_sym])
          end
        elsif name.to_s =~ /^(\w*)$/ && !@data.has_key?($1.to_sym)
          args.first
        else
          super
        end
      end

      def to_data_array(arr)
        arr.map do |item|
          if item.is_a?(Hash)
            self.class.new(item)
          elsif item.is_a?(Array)
            to_data_array(item)
          else
            to_parsed_data(item)
          end
        end
      end

      def to_parsed_data(val)
        return true if val == 'true'
        return false if val == 'false'

        date = DateTime.parse(val) if val =~ /^[0-9]{4}\-[0-9]{2}\-[0-9]{2}/ rescue nil
        return date if date.is_a?(DateTime)

        return Integer(val) if val =~ /^[0-9]+$/ rescue nil
        return Float(val) if val =~ /^[0-9]+\.[0-9]+$/ rescue nil

        val
      end

  end
end