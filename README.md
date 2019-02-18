## Instructions

Build 2 small applications (micro-services) written with Elixir. Each of the services should have own purpose of existing and single responsibility.

### Orders Application

1. Responsible for orders management
2. Each order can be at the single state at the time
3. Order states - created, confirmed, delivered, cancelled
4. After order was created Orders App should trigger Payments App call to process a payment for the current order
5. An Application should have endpoints to:
   * create an order
   * cancel an order
   * check order status

### Payments Application

1. Responsible for payment processing
2. Payments App should handle requests by Order App to verify payment transaction and confirmed or declined an order.
3. The logic behind the payment processing should be mocked and return a random result to the Orders App.

## General Scenario

1. Calling Orders App endpoint to create an Order
2. An order should be created in DB with the created state
3. Orders App makes a call to Payment App with the order information and mocked auth details.
4. Payment App processes an order (logic can be mocked) and returns random response confirmed or declined
5. Orders App updates order based on the response from the Payments App
   * declined ⇒ moves order to the canceled state
   * confirmed ⇒ moves order to the confirmed state
6. After X amount of seconds confirmed orders should automatically be moved to the delivered state.


## Other Notes:

Task should be completed with the all necessary practices in your opinion: CodeStyle, Lint, Tests etc.
Feel free to use your creativity to accomplish the task.


-- WIP

-- Runing the code  
-- Require Redis for clustering  
-- reuqire postgres configuration in config/dev.exs  
```elixir
export NODE="sam_media"
export PORT=4000

mix deps.get
mix deps.compile

mix do event_store.create, event_store.init
mix ecto.create
mix ecto.migrate
mix phx.swagger.generate
mix phx.server
```

## Open http://localhost:4000/swagger/index.html#/  

For testing
```elixir
export NODE="sam_media"
export PORT=4000
export MIX_ENV=test

mix deps.get
mix deps.compile

mix do event_store.create, event_store.init
mix ecto.create
mix ecto.migrate
mix test
```






Pros Of Solution:
* CQRS based application  
* Read Projection can be destroyed and created as useful  
* Horizontally scalable with Just Config changes. No Codebase touch  
* Hot Code reloading with Simple steps.
