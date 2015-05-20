class DemosController < ApplicationController
  def new
    @demo = Demo.new
  end

  def create
    @demo = Demo.new(demo_params)
    if @demo.save
      DemoConfirmationMailer.confirmation_email(@demo).deliver_later(queue: ApplicationJob::DEFAULT_QUEUE) #Que uses blank queue name
      respond_to do |format|
        format.html {
          redirect_to root_path, notice: 'OK, check your email.'          
        }
        format.json {
          render json: @demo.to_json(include: :requestor), status: :created
        }
      end
    else
      respond_to do |format|
        format.html {
          flash[:alert] = "Please correct the errors below."
          render 'new'
        }
        format.json {
          render json: @demo.errors.full_messages, status: :bad_request
        }
      end
    end
  end

  def show
    @demo = Demo.find_by(token: params[:token]) or raise "Invalid request"

    @demo.confirmed! if @demo.pending?

    @description = @demo.display_description

    if @demo.ready? #fulfilled and not expired
      @url = @demo.published_url
    elsif @demo.provisionable?
      @demo.provision_later
    elsif @demo.error?
      @error = @demo.provisioning_error
    end

    respond_to do |format|
      format.html
      format.json {
        render json: @demo.to_json, status: (@demo.error? || @demo.expired? ? :bad_request : :ok)
      }
    end
  end

  private

  def demo_params
    params.require(:demo).permit(:email, :template_id, :description)
  end
end