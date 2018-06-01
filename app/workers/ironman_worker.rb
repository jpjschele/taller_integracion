class IronmanWorker
  include Sidekiq::Worker

  def perform(order)
    # Do something
    puts 'Working...'
    puts order
  end
end
