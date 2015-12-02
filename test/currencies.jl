# Custom currencies
@usingcustomcurrency xbt "Bitcoin (100 satoshi unit)" 2

@test contains(string(10xbt), "xbt")
@test contains(string(10xbt), "10.00")
@test 10xbt - 5xbt == 5xbt
@test StaticBasket([10xbt, 10USD]) - 10USD == 10xbt

custom = newcurrency!(:custom, "Custom Currency", 6)

@test contains(string(custom), "1.000000")
@test contains(string(custom), "custom")
@test 10custom / 10000000 == 0.000001custom

# Currency Info
@test currencyinfo(:USD) == "United States dollar"
@test currencyinfo(:custom) == "Custom Currency"
@test currencyinfo(10custom) == "Custom Currency"
@test currencyinfo(Monetary{:xbt}) == "Bitcoin (100 satoshi unit)"

# Currency
@test currency(2GBP) == :GBP
@test currency(zero(Monetary{:CNY})) == :CNY
@test currency(10xbt) == :xbt
@test currency(custom) == :custom
