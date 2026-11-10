# Row-Level Security Tests

Mechanism: SecurityMap (UserEmail, TerritoryKey) filters dim_Territory using
USERPRINCIPALNAME(). Roles: RegionManager (filtered), Executive (no filter).
Tested in Power BI Desktop with Modeling > View as.

| # | User / Role | Expected | Actual | Result |
|---|-------------|----------|--------|--------|
| 1 | manager.europe@example.com | Only France, Germany, UK | 3 regions. Sales 19,837,684.28 (SQL: 19,837,684.28, 27,042 lines) | Pass |
| 2 | manager.us@example.com | Only Northwest, Northeast | 2 regions. Sales 23,024,317.03 (SQL: 23,024,317.03, 22,701 lines) | Pass |
| 3 | nobody@example.com | No data | No data shown | Pass |
| 4 | Executive | All 10 regions, about 109.85M | All 10 regions, total shown (see screenshot) | Pass |

Screenshots are in tests/rls_results/.

## Known limitations
- RLS filters sales rows by territory. Product and customer names may still
  appear in slicers with blank values.
- RLS does not apply to workspace Admins, Members and Contributors.
- Role assignment to real users needs the Power BI Service, which was not available.
