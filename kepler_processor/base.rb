require 'fileutils'

module KeplerProcessor
  class Base

    def initialize(input_filename, output_path, force_overwrite)
      @input_filename   = input_filename
      @output_path      = output_path
      @force_overwrite  = force_overwrite
      @input_data       = []
    end

    def run
      puts "Processing file #{@input_filename}"
      read_in_data
      split_comments!
      parse_header_attributes
      convert_from_string!
      yield
      save!
      puts "Finished processing file #{@input_filename}"
    end

    def full_output_filename
      "#{@output_path}/#{output_filename}"
    end

    private

      def read_in_data
        File.new(@input_filename, "r").each { |line| @input_data << line }
        # file closes automatically because it's opened in this method
        raise NoDataError if @input_data.empty?
      end

      def split_comments!
        # matches (=~) regular expression (//) hash at start of line (^)
        @comments, @input_data = @input_data.partition { |line| line =~ /^#/ }
      end

      def parse_header_attributes
        # select lines from comments containing a colon, map them into an array, remove the '#' and split
        # about that colon. Create a hash out of the result.
        @attributes = @comments.select { |line| line.include? ":" }.map { |line| line.gsub("# ", "").split ":" }.to_hash
      end

      def convert_from_string!
        # convert @input_data to a two dimensional float array: time, flux
        @input_data.map! { |line| line.split(" ").map(&:to_f)[0..1] }
      end

      def output_filename
        nil # defaults to nil, child class must override output_filename in order to save
      end

      def save!
        if output_filename
          @output_data ||= @input_data
          ::FileUtils.mkpath @output_path
          raise FileExistsError if File.exist?(full_output_filename) && !@force_overwrite
          puts "Writing output to #{full_output_filename}"
          output_file = File.new full_output_filename, "a+" # 'a+' for all - read, write... everything
          # confine the size of the file to zero if forcing overwrite, thereby emptying the file
          output_file.truncate(0) if @force_overwrite
          # output the array, joining each element separated by tab, and each record by newline
          @output_data.each { |record| output_file << "#{record.join("\t")}\n" }
        end
      end

  end
end
