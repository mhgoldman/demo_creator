class DemosController < ApplicationController
  def new
    @demo = Demo.new
  end

  def create
    @demo = Demo.new(demo_params)
    if @demo.save
      DemoConfirmationMailer.confirmation_email(@demo).deliver_later(queue: ApplicationJob::DEFAULT_QUEUE) #Que uses blank queue name
      redirect_to root_path, notice: 'OK, check your email.'
    else
      flash[:alert] = "Please correct the errors below."
      render 'new'
    end
  end

  def show
    @demo = Demo.find_by(token: params[:token]) or raise "Invalid request"

    @demo.confirmed! if @demo.pending?

    if @demo.ready? #fulfilled and not expired
      @message = :ready
      @url = @demo.published_url
    elsif @demo.provisioning?
      @message = :provisioning
    elsif @demo.provisionable?
      @demo.provision_later
      @message = :started_provisioning      
    else #expired?
      @message = :expired
    end
  end

  private

  def demo_params
    params.require(:demo).permit(:email, :template_id, :description)
  end
end