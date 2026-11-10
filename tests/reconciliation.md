# Reconciliation Results

Source: AdventureWorks2025 (OLTP). Warehouse: AW_DW.

| Check | Source | Warehouse | Result |
|---|---|---|---|
| Order lines | 121,317 | 121,317 | Pass |
| Revenue | 109,846,381.3999 | 109,846,381.4250 | Pass (0.025 rounding: source has 6 decimals, warehouse 4) |
| Territories | 10 | 11 (10 + Unknown) | Pass |
| Products | 504 | 505 (504 + Unknown) | Pass |
| Customers | 19,820 | 19,821 (19,820 + Unknown) | Pass |
| Customers by type | 18,484 individual, 1,336 store | same, plus 1 Unknown | Pass |
| Sales people | 17 | 18 (17 + Unknown) | Pass |
| Fact rows with unknown product, customer or territory | n/a | 0, 0, 0 | Pass |
| Fact rows with no salesperson (online orders) | n/a | 60,398 | Expected |

## Defect found and fixed
dim.Customer first labelled 635 store customers as individuals and left their
country as Unknown. Cause: those customers have both a PersonID and a StoreID,
and the first script tested PersonID. Fix: test StoreID instead and update the
rows in place, so surrogate keys and fact rows were unaffected.
