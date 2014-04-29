require 'json'
require 'ruby-fann'
require 'byebug'
require 'gruff'
require 'ruby_fann/neurotica'


class Tweet
  MAX_EPOCH = 100
  DESIRED_MSE = 0.01


  @inputs_size = 144
  @mse_errors_train = []
  @mse_errors_test = []


  def self.draw_plot
    g = Gruff::Line.new
    g.title = 'Gruff Example'
    # g.data "Train data MSE", @mse_errors_train
    g.data "Test data MSE", @mse_errors_test
    g
  end

  def self.build_train_data
    @train_data = RubyFann::TrainData.new(inputs: inputs, desired_outputs: outputs)
  end

  def self.build_neuron_network  
    @network = RubyFann::Standard.new(num_inputs: @inputs_size, hidden_neurons: [@inputs_size/2, @inputs_size/4], num_outputs: 1)
  end

  def self.file=(file)
    @file = File.read(file)
    @json_data = JSON.parse(@file)
  end
    
  def self.get_tweet(index)
    record = @json_data.to_a[index]
    attrs = {}
    attrs[:name] = record[0]
    attrs[:value] = record[1]
    attrs
  end

  def self.inputs
    @inputs ||= begin
      result = []
      @json_data.map do |tweet, data|
        result << data["code"].split("").map(&:to_i)
      end
      result
    end
  end

  def self.outputs
    @outputs ||= begin
      result = []
      @json_data.map do |tweet, data|
        result << [data["weight"].to_f]
      end
      result
    end
  end

  def self.run_network
    network = Tweet.build_neuron_network
    network.set_activation_function_hidden(:sigmoid_symmetric)
    network.set_activation_function_output(:sigmoid_symmetric)
    network.set_train_stop_function(:mse) 

    train_data = Tweet.build_train_data
    network.train_on_data(train_data, MAX_EPOCH, 10, DESIRED_MSE)
    Tweet.file = "calculate_error/test_collection.json"
    minserror = 0
    Tweet.inputs.each_with_index do |test_input, index|
      tweet = Tweet.get_tweet(index)
      result = network.run(test_input)
      # puts "#{tweet[:name]} <<<<->>> #{result}"
      error = (result.first - tweet[:value]["weight"])**2
      # @mse_errors_test << error
      minserror += error
    end
    minserror = minserror/(2*Tweet.inputs.count)
    puts "Error: #{minserror}"
  end

  def self.draw_neurotica_plot
    paint = RubyFann::Neurotica.new
    paint.graph(@network, "tmp/plot.png")
    File.open("tmp/plot.png")
  end

end

# ((x1 - xr2)**2 + .... + (xn - xrn)**2)/2n 


