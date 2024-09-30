# Containerized apps

A short while ago, I switched to using atomic Linux distros, namely [https://projectbluefin.io/](Bluefin). There are few applications that I use,
which do not provide flatpaks, and as a result I must either "layer" their packages, or run some custom installer into a user-owned location. To
reduce the hassle, I've created "boxed" versions for:

- Citrix Workspace App: [box-citrix](./box-citrix)
- Interactive Brokers Trader Workstation: [box-ib-tws](./box-ib-tws)
