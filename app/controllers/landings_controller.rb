# frozen_string_literal: true

class LandingsController < ApplicationController
  skip_before_action :login_if_not

  def index
    render :index, layout: false
  end

  def create
    return redirect_to("/") if params[:email].blank?

    WaitingList.create(email: params[:email])
    render :done, layout: false
  end
end
