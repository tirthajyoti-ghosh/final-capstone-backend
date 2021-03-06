class AppointmentsController < ApplicationController
  include CurrentUserConcern
  include ProcessDataConcern

  before_action :validate_login

  def index
    appointments = Appointment.includes(:apartment).where(user_id: @current_user.id)

    render json: { appointments: process_appointments(appointments) }
  end

  def create
    appointment = Appointment.new(
      date: params[:appointment][:date],
      apartment_id: params[:appointment][:apartment_id],
      user_id: @current_user.id
    )

    if appointment.save
      render json: { message: 'Appointment created!' }, status: :created
    else
      render json: { message: 'Request failed. Try again.' }, status: 500
    end
  end

  def destroy
    appointment = Appointment.find(params[:id])

    render json: { message: 'This appointment does not exist.' }, status: 404 unless appointment

    if appointment.user_id == @current_user.id
      appointment.destroy
      render json: { message: 'Appointment deleted!' }
    else
      render json: { message: 'You are not authorized to perform this action.' }, status: 401
    end
  end

  private

  def validate_login
    render json: { status: 'Unauthorized', message: 'You need to login first.' }, status: 401 unless @current_user
  end
end
