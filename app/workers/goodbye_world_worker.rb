class GoodbyeWorldWorker
  include Sidekiq::Worker

  def perform(*args)
    puts "GOOODDD BYEEEEEE!!"
  end
end
