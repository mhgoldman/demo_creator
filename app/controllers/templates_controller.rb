class TemplatesController < ApplicationController
  def index
    respond_to do |format|
      format.html {
        render nothing: true
      }
      format.json {
        render json: Template.all.to_json        
      }
    end
  end
end
