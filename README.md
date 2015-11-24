# Currencies

[![Build Status](https://travis-ci.org/TotalVerb/Currencies.jl.svg?branch=master)](https://travis-ci.org/TotalVerb/Currencies.jl)

The currency-related information for this package comes from [this Wikipedia page](https://en.wikipedia.org/wiki/ISO_4217#cite_note-divby5-9).

## Usage
The `Currencies` module exports the `Monetary` type, and convenience values `usd` and `cad`. They can be used as follows:

* `1usd + 2usd  # 3.00 USD`
* `3 * 1.5usd  # 4.50 USD`
