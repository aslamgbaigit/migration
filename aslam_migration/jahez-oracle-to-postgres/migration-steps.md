## Before Friday
- On node #1:
  - sudo su to root
  - Create  a screen session, and run:
```bash
./migrate-part-1.sh ENV_AME
```

- On node #2:
  - sudo su to root
  - Create  a screen session, and run:
```bash
./migrate-part-2.sh ENV_AME
```

- On node #3:
  - sudo su to root
  - Create  a screen session, and run:
```bash
./migrate-part-3.sh ENV_AME
```

## On Friday

Run the following on parallel on each node:

- On Node #1
  - Create a screen session `s1`
    - Run `migrate-batch-01.sh` (~10 minutes)
    - Then, Run `migrate-batch-02.sh` (~20 minutes)
  - Create a screen session `s2`
    - Run `migrate-batch-05.sh` (~30 minutes)
  - Create a screen session `s3`
    - Run `migrate-batch-06-oauth-access-token.sh` (~20 minutes)
  - Create a screen session `s4`
    - Run `migrate-batch-07-jz-order-payment-transaction.sh` (~20 minutes)



- On Node #2
  - Create a screen session `s1`
    - Run `migrate-batch-03-menu-item.sh` (~1 hour)


- On Node #3
  - Create a screen session `s1`
    - Run `migrate-batch-04-pending-menu-item.sh` (~1 hour)
