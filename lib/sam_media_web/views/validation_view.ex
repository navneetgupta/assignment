defmodule SamMediaWeb.ValidationView do
  use SamMediaWeb, :view

  def render("error.json", %{errors: errors}) do
    %{errors: errors}
  end
end
