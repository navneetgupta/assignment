defmodule SamMedia.Support.Validators.SecurityCode do
  use Vex.Validator

  def validate(value, _options) do
    Vex.Validators.By.validate(value,
      function: &valid_security_code?/1,
      allow_nil: false,
      allow_blank: false
    )
  end

  defp valid_security_code?(code) do
    String.length(code) == 3
  end
end
