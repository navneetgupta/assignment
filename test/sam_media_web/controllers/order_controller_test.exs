defmodule SamMediaWeb.OrderControllerTest do
  use SamMediaWeb.ConnCase

  import SamMedia.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "list orders" do
    test "should list down all the orders", %{conn: conn} do
      conn = get(conn, order_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end
end
