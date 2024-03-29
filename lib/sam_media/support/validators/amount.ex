defmodule SamMedia.Support.Validators.Amount do
  use Vex.Validator

  def validate(value, _options) do
    Vex.Validators.By.validate(value,
      function: &valid_amount?/1,
      allow_nil: false,
      allow_blank: false
    )
  end

  defp valid_amount?(amount) do
    amount > 0
  end
end
