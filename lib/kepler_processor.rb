require 'gnuplot'
require 'gsl'
require 'kepler_dft'

require_relative 'kepler_processor/monkey_patches.rb'

module KeplerProcessor
  class FileExistsError < StandardError; end
  class NoDataError < StandardError; end
end

require_relative 'kepler_processor/fourier_transformable.rb'
require_relative 'kepler_processor/saveable.rb'
require_relative 'kepler_processor/input_file_processor_base.rb'
require_relative 'kepler_processor/task_base.rb'
require_relative 'kepler_processor/multifile_task_base.rb'
require_relative 'kepler_processor/tasks.rb'
require_relative 'kepler_processor/version.rb'
