# frozen_string_literal: true

class ShiftMatchesController < AdminController
  before_action :set_shift_match, only: %i[show edit update destroy]

  def index
    @shift_matches = ShiftMatch.all
  end

  def show; end

  def new
    @shift_match = ShiftMatch.new
    set_form_dropdowns
  end

  def edit
    set_form_dropdowns
  end

  def create
    @shift_match = ShiftMatch.new(shift_match_params)

    if @shift_match.save
      redirect_to matches_path, notice: 'Match was successfully connected to a Shift.'
    else
      set_form_dropdowns
      render :new
    end
  end

  def update
    if @shift_match.update(shift_match_params)
      redirect_to matches_path, notice: 'Match was successfully updated.'
    else
      set_form_dropdowns
      render :edit
    end
  end

  def destroy
    @shift_match.destroy
    redirect_to shift_matches_url, notice: 'Shift match was successfully destroyed.'
  end

  private

  def set_shift_match
    @shift_match = ShiftMatch.find(params[:id])
  end

  def set_form_dropdowns
    @shifts = if action_name == 'new'
      Shift.active
    else
      Shift.all
    end

    if params[:person_id].present?
      shift = Shift.today.where(person_id: params[:person_id]).last
      unless shift
        team = Team.where("name ILIKE '%dispatch%'").first_or_create!(name: 'Dispatch', organization: context.host_organization)
        shift = Shift.create!(team: team, notes: 'autogenerated', person_id: params[:person_id], started_at: Time.zone.today, ended_at: Time.zone.today + 24.hours)
      end
      @shift_id = shift.id
    end
  end

  def shift_match_params
    params.require(:shift_match).permit(:shift_id, :match_id, :notes)
  end
end
