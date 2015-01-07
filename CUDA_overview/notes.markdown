```haskell
fm self 0 = 1
fm self n = n * (self self $ n-1)
```
