Displaying Currencies
=====================

There are two ways to display a :class:`Monetary` value. The representation used
by :func:`show` and :func:`print` is the same, and is fairly compact. For a
richer display, use :func:`writemime`, which has a more user-friendly
representation. To get the :func:`writemime` representation into a string, use
the :func:`sprint` function::

  sprint(writemime, "text/plain", 100USD)  # "100.00 USD"
