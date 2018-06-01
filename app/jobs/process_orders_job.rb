class ProcessOrdersJob < ApplicationJob
  queue_as :default

  #rescue_from(ErrorLoadingSite) do
  #  retry_job wait: 2.minutes, queue: :default
  #end

  def perform(*args)
    order = {id: '123spree456puto789'}
    puts '[DEBUG] running ProcessOrdersJob'
    IronmanWorker.perform_async order
  end
end
