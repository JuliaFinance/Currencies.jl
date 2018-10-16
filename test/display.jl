# Display methods (show & print & writemime) tests
using Base64

@testset "Output" begin

@testset "text/plain" begin
    @test occursin("1.00", stringmime("text/plain", 1USD))
    @test occursin("1", stringmime("text/plain", 1JPY))
    @test occursin("CAD", stringmime("text/plain", Basket([1USD, 1CAD])))
    @test occursin("USD", stringmime("text/plain", Basket([1USD, 1CAD])))
    @test occursin(
        "200.00 EUR",
        stringmime("text/plain", Basket([100USD, 200EUR])))
    @test !occursin(
        "CAD", stringmime("text/plain", Basket([1USD, 1CAD, -1CAD])))
    @test stringmime("text/plain", +USD) == "1.00 USD"
    @test stringmime("text/plain", -USD) == "−1.00 USD"

    @test stringmime("text/plain", majorunit(Monetary{:USD, BigInt, 5})) ==
        "1.00000 USD"
    @test stringmime("text/plain", -Monetary(:JPY, precision=2)) ==
        "−1.00 JPY"
    @test stringmime("text/plain", 7.2512Monetary(:XAU; precision=4)) ==
        "7.2512 XAU"

    # with compact IOContext
    buf = IOBuffer()
    show(IOContext(buf, :compact => true), "text/plain", 1USD)
    @test String(take!(buf)) == "1.0USD"
end

@testset "text/latex" begin
    @test stringmime("text/latex", 100USD) == "\$100.00\\,\\mathrm{USD}\$"
    @test stringmime("text/latex", -100JPY) == "\$-100\\,\\mathrm{JPY}\$"
    @test stringmime("text/latex", 0GBP) == "\$0.00\\,\\mathrm{GBP}\$"
    @test stringmime("text/latex", zero(Monetary{:EUR, Int, 0})) ==
        "\$0\\,\\mathrm{EUR}\$"
end

@testset "text/markdown" begin
    basketstr = stringmime("text/markdown", Basket([USD, 20CAD, -10JPY]))

    @test occursin("`Basket`", basketstr)
    @test occursin("\$3\$-currency", basketstr)
    @test occursin(" - \$-10\\,\\mathrm{JPY}\$", basketstr)
end

@testset "print & show" begin
    @test string(USD) == "1.0USD"
    @test string(0.01USD) == "0.01USD"
    @test string(20JPY) == "20.0JPY"

    # this test is a bit complicated because order is undefined
    basketstr = string(Basket([USD, 20CAD, -10JPY]))
    @test occursin("Basket([", basketstr)
    @test occursin("-10.0JPY", basketstr)
    @test occursin("20.0CAD", basketstr)

    # test compatibility between show & print
    @test sprint(show, 0.02USD) == string(0.02USD)
end

end  # testset output

@testset "format" begin
    # internals
    @test Currencies.CurrencyFormatting.digitseparate(20160408, "'", (3, 3)) == "20'160'408"
    @test Currencies.CurrencyFormatting.digitseparate(12345678, " ", (3, 3)) == "12 345 678"
    @test Currencies.CurrencyFormatting.digitseparate(1, ",", (3, 3)) == "1"
    @test Currencies.CurrencyFormatting.digitseparate(12345678, ",", (3, 2)) == "1,23,45,678"

    # default (finance) style
    @test format(100USD) == "100.00 USD"
    @test format(8050.20USD) == "8050.20 USD"
    @test format(-100USD) == "(100.00) USD"
    @test format(-8050.20EUR) == "(8050.20) EUR"
    @test format(-5JPY) == "(5) JPY"
    @test format(0CAD) == "— CAD"

    # us style
    @test format(1000USD, styles=[:us]) == "USD 1,000.00"
    @test format(1000JPY, styles=[:us]) == "JPY 1,000"
    @test format(19970716.14AUD, styles=[:us]) == "AUD 19,970,716.14"
    @test format(-1100.55USD, styles=[:us]) == "USD −1,100.55"

    # european style
    @test format(-15USD, styles=[:european]) == "−15,00 USD"
    @test format(-1050EUR, styles=[:european]) == "−1.050,00 EUR"
    @test format(5123JPY, styles=[:european]) == "5.123 JPY"
    @test format(12345678.90GBP, styles=[:european]) == "12.345.678,90 GBP"
    @test format(0USD, styles=[:european]) == "0,00 USD"

    # indian style
    @test format(20000000INR, styles=[:indian]) == "INR 2,00,00,000.00"

    # combined us & finance style
    @test format(-1100.55USD, styles=[:us, :finance]) == "USD (1,100.55)"
    @test format(805.03CAD, styles=[:us, :finance]) == "CAD 805.03"
    @test format(1111111.11AUD, styles=[:us, :finance]) == "AUD 1,111,111.11"
    @test format(0USD, styles=[:us, :finance]) == "USD —"

    # combined european & finance styles
    @test format(-1100.55EUR, styles=[:european, :finance]) == "(1.100,55) EUR"
    @test format(-0.11EUR, styles=[:european, :finance]) == "(0,11) EUR"
    @test format(0AUD, styles=[:european, :finance]) == "— AUD"

    # local style
    @test format(1000AUD, styles=[:local]) == "AUD 1000.00"
    @test format(1000EUR, styles=[:local]) == "1000.00 EUR"

    # brief style
    @test format(-15USD, styles=[:brief]) == "−15.00\$"
    @test format(8.05CAD, styles=[:brief]) == "8.05\$"
    @test format(11.11EUR, styles=[:brief]) == "11.11€"

    # combined brief & xxx style
    @test format(-11.11EUR, styles=[:brief, :finance]) == "(11.11€)"
    @test format(-11.11USD, styles=[:brief, :us]) == "−\$11.11"
    @test format(-11.11CAD, styles=[:brief, :european]) == "−11,11\$"
    @test format(-123456.78USD, styles=[:brief, :finance, :us]) ==
        "(\$123,456.78)"
    @test format(805.11GBP, styles=[:brief, :finance, :european]) ==
        "805,11£"

    # combined LaTeX style
    @test format(-11.11AUD, styles=[:latex, :finance]) ==
        "(11.11)\\,\\mathrm{AUD}"
    @test format(11.11AUD, styles=[:latex, :us]) == "\\mathrm{AUD}\\,11.11"
    @test format(8.05AUD, styles=[:latex, :brief, :european]) ==
        "8,05\\mathrm{\\\$}"

    # test declarative nature (duplicates don't matter)
    @testset "Declarative" begin
        for style in (:us, :european, :brief, :finance, :latex)
            for amt in (8000.05AUD, -0.15GBP, 13JPY)
                @test format(amt, styles=[style]) ==
                    format(amt, styles=[style, style])
            end
        end
    end

    # can't combine US & european
    @test_throws Currencies.DeclarativeFormatting.IncompatibleFormatException format(
        USD, styles=[:us, :european])

    # big numbers
    @test format(Monetary{:USD,BigInt,10}(1e4)) == "10000.0000000000 USD"
end
