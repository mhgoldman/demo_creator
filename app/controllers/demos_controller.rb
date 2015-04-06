class DemosController < ApplicationController
  def new
    @demo = Demo.new
  end

  def create
    @demo = Demo.new(demo_params)
    if @demo.save
      DemoConfirmationMailer.confirmation_email(@demo).deliver
      redirect_to root_path, notice: 'OK, check your email.'
    else
      flash[:alert] = "Nope, try again."
      render 'new'
    end
  end

  def show
    @demo = Demo.find_by(token: params[:token]) or raise "Invalid request"

    @demo.confirmed! unless @demo.confirmed?

    if @demo.ready? #fulfilled and not expired
      render text: "ok, here is your environment: #{@demo.published_url}"
    elsif @demo.provisioning?
      render text: "hold your horses, i'm working on it."
    elsif @demo.provisionable?
      # DELAY @demo.provision!
      render text: "hazzah! time to provision!"
    else #expired?
      render text: "oh snap, you're expired"
    end
  end

  private

  def demo_params
    params.require(:demo).permit(:email, :template_id, :description)
  end
end