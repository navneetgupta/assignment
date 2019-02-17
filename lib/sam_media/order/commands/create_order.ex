defmodule SamMedia.Order.Commands.CreateOrder do
  alias __MODULE__

  defstruct uuid: "",
            amount: 0,
            card_number: "",
            card_expiry: "",
            card_security_code: "",
            card_holder_name: "",
            user_name: "",
            user_mobile: ""

  use ExConstructor
  use Vex.Struct

  validates(:uuid, uuid: true)

  validates(:amount,
    presence: [message: "can't be empty"],
    amount: true
  )

  validates(:card_number,
    presence: [message: "can't be empty"],
    card_number: true
  )

  validates(:card_holder_name,
    presence: [message: "can't be empty"],
    string: true
  )

  validates(:user_name,
    presence: [message: "can't be empty"],
    string: true
  )

  validates(:user_mobile,
    presence: [message: "can't be empty"],
    string: true
  )

  validates(:card_security_code,
    presence: [message: "can't be empty"],
    card_security_code: true
  )

  def assign_uuid(%CreateOrder{} = create_order, uuid) do
    %CreateOrder{create_order | uuid: uuid}
  end
end
