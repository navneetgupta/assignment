defmodule SamMedia.Support.Validators.ExpiryDate do
  use Vex.Validator

  def validate(value, _options) do
    Vex.Validators.By.validate(value,
      function: &valid_expiry?/1,
      allow_nil: false,
      allow_blank: false
    )
  end

  defp valid_expiry?(date) do
    true
  end
end
