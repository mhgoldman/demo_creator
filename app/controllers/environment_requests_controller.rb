class EnvironmentRequestsController < ApplicationController
  def new
    @environment_request = EnvironmentRequest.new
  end

  def create
    @environment_request = EnvironmentRequest.new(environment_request_params)
    if @environment_request.save
      EnvironmentRequestConfirmationMailer.confirmation_email(@environment_request).deliver
      redirect_to root_path, notice: 'OK, check your email.'
    else
      flash[:alert] = 'Nope, try again.'
      render 'new'
    end
  end

  def show
    @environment_request = EnvironmentRequest.find_by(token: params[:token]) or raise "Invalid request"
    if @environment_request.ready? #fulfilled and not expired
      render text: "ok, you can have your environment now."
    elsif @environment_request.provisioning?
      render text: "hold your horses, i'm working on it."
    elsif @environment_request.provisionable?
      # DELAY @environment_request.provision!
      render text: "hazzah! time to provision!"
    else #expired?
      render text: "oh snap, you're expired"
    end
  end

  private

  def environment_request_params
    params.require(:environment_request).permit(:email, :template_id, :description)
  end
end