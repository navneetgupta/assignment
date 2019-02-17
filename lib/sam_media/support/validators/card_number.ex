defmodule SamMedia.Support.Validators.CardNumber do
  use Vex.Validator

  def validate(value, _options) do
    Vex.Validators.By.validate(value,
      function: &valid_card_number?/1,
      allow_nil: false,
      allow_blank: false
    )
  end

  defp valid_card_number?(card_number) do
    String.length(card_number) == 16
  end
end
