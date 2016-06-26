Base.@deprecate_binding StaticBasket Basket
Base.@deprecate_binding DynamicBasket Basket

@deprecate simplefv(pv, rate, periods) pv * (one(rate) + rate * periods)
@deprecate compoundfv(pv, rate, periods) pv * (one(rate) + rate)^periods
