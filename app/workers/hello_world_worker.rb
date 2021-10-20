class HelloWorldWorker
  include Sidekiq::Worker

  def perform(*args)
    puts "Hello World!"
  end
end
