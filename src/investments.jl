# investment math functions

# calculate future value
"""
Compute the future value of the given monetary amount, at the given interest
rate, compounded each period on the principal only. This is known as "simple
interest"; note that this is very rare in practice. For example, to find the
future value of \$1000 (US) invested today in 12 years, at a simple interest
rate of 5% per year, compute:

    simplefv(1000USD, 0.05, 12)

This computation rounds only once at the end. If the amounts in practice are
rounded, then this result of this function will be incorrect.

This method is generic; any type for the PV is accepted provided that it is
compatible with real multiplication. Negative values for the rate and the period
are allowed.
"""
function simplefv(pv, rate::Real, periods::Integer)
    pv * (one(rate) + rate * periods)
end

"""
Compute the future value of the given monetary amount, at the given interest
rate, compounded each period. For example, to find the future value of \$1000
(US) invested today in 12 years, at a rate of 3% per year, compute:

    compoundfv(1000USD, 0.03, 12)

This computation assumes exact compounding, and rounds only once at the end. If
the compounding method in practice is rounded, then this result of this function
will be incorrect.

This method is generic; any type for the PV is accepted provided that it is
compatible with real multiplication. Negative values for the rate and the period
are allowed.
"""
function compoundfv(pv, rate::Real, periods::Integer)
    pv * (one(rate) + rate)^periods
end
