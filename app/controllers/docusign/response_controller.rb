class Docusign::ResponseController < ApplicationController

  def index
    @event = params[:event]
    @message = params[:message]
    @template = "docusign/response/codes/#{@event}"
    @envelope = Docusign::Envelope.find(params[:id])
    @envelope.update(status: @event) if @envelope.present?
  end

end
