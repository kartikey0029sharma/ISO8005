# ISO8005 TAB Report - Metrics Glossary

This document defines every metric, KPI, and formula used throughout the ISO8005 report.

---

## Core Metrics

### 1. Monthly Active Local Customers (MALC) ⭐

**Definition**: The number of unique local customers who place at least one online order, click-and-collect order, or hold an active subscription within a calendar month.

**Formula**:
```r
malc <- orders %>%
  filter(region %in% c("Newcastle", "Gateshead", "North Tyneside", "South Tyneside")) %>%
  group_by(month) %>%
  summarise(malc = n_distinct(customer_id))
```

**Why it matters**: 
- Directly reflects TAB's core business goal: grow local digital customers.
- Captures all channels (online orders, subscriptions, click-and-collect).
- Accounts for repeat behaviour (customer active in Jan + Feb = 2 x MALC, not double-counted as 1).

**Benchmark**: TAB baseline is [X] customers/month. Industry target: +30% over 12 months = [Y] customers.

---

## E-Commerce Metrics

### 2. Conversion Rate (CVR)

**Definition**: The percentage of website sessions that result in a completed order.

**Formula**:
```r
cvr = orders / sessions * 100
```

**Example**: 100 sessions → 3 orders = 3% CVR.

**Benchmark**: 
- E-commerce average: 2–3%
- Bakery/artisan goods: 2.5–3.5%
- TAB target: 3.0–3.5%

**How to improve**:
- Simplify checkout (guests allowed, 1-page)
- High-quality product photos
- Trust signals (reviews, allergen info, delivery promise)
- Mobile optimization

---

### 3. Average Order Value (AOV)

**Definition**: Average revenue per order.

**Formula**:
```r
aov = total_revenue / total_orders
```

**Example**: £5,000 revenue / 100 orders = £50 AOV.

**Why it matters**: Drives revenue without needing more traffic.

**How to improve**:
- Upsell (recommend larger loaves, pastry packs)
- Subscription discounts (£50/month for Bread Box vs £12/week)
- Bundle offers ("Sourdough + pastries combo")

---

## Paid Advertising Metrics

### 4. Return on Ad Spend (ROAS)

**Definition**: Revenue generated per £1 spent on advertising.

**Formula**:
```r
roas = attributed_revenue / ad_spend
```

**Example**: £100 spend → £300 revenue = 3.0x ROAS.

**Benchmark**:
- Break-even: 2.0x ROAS (covers ad spend + profit margin ~20%)
- Healthy: 3.0x–4.0x ROAS
- Excellent: 5.0x+ ROAS

**Interpretation**:
- ROAS 2.0 = profitable but tight margins
- ROAS 3.0 = scalable, good reinvestment headroom
- ROAS <2.0 = unprofitable, pause the channel

---

### 5. Customer Acquisition Cost (CAC)

**Definition**: Average cost to acquire one new customer via paid advertising.

**Formula**:
```r
cac = total_ad_spend / new_customers_acquired
```

**Example**: £500 spend → 10 new customers = £50 CAC.

**Key metric**: Compare to **Customer Lifetime Value (CLV)** or **first order AOV**.

- If CAC > CLV, the channel is unprofitable long-term.
- If CAC < AOV, the first order already covers acquisition cost.

**TAB target**: CAC < 25% of AOV (e.g., if AOV = £50, CAC should be <£12.50).

---

### 6. Cost Per Click (CPC)

**Definition**: Average cost per click on a paid ad.

**Formula**:
```r
cpc = total_ad_spend / total_clicks
```

**Example**: £100 spend → 500 clicks = £0.20 CPC.

**Why it matters**: Indicates keyword competitiveness and ad quality score.

**Interpretation**:
- High CPC (>£1.00) = competitive keywords, poor quality score, or niche audience
- Low CPC (<£0.10) = low competition, good quality score, broad keywords

---

### 7. Click-Through Rate (CTR)

**Definition**: The percentage of impressions that result in clicks.

**Formula**:
```r
ctr = clicks / impressions * 100
```

**Example**: 10,000 impressions → 250 clicks = 2.5% CTR.

**Benchmark**:
- Google Search Ads: 1–3%
- Google Shopping: 0.5–2%
- Facebook/Instagram: 0.5–1.5%
- Display Ads: 0.1–0.5%

**How to improve**:
- Better ad copy (clarity, benefit-driven)
- Keyword match (exact match has higher CTR)
- Ad extensions (location, callout, price)

---

## Traffic & Engagement Metrics

### 8. Sessions

**Definition**: A session is a group of interactions on a website within a given time period (typically 30 minutes).

**Example**: User visits homepage, clicks "Shop", views products, leaves. = 1 session (multiple pageviews).

**Why it matters**: Reflects traffic volume and marketing effectiveness.

---

### 9. Bounce Rate

**Definition**: The percentage of sessions that have only one pageview (users who left without further interaction).

**Formula**:
```r
bounce_rate = sessions_with_1_pageview / total_sessions * 100
```

**Benchmark**:
- Low bounce: <30% (users exploring, finding value)
- Medium: 30–50% (acceptable)
- High bounce: >50% (consider UX, relevance, or landing page quality)

**How to reduce bounce**:
- Clear value proposition (hero banner)
- Intuitive navigation
- Fast load time
- Mobile optimization

---

## Subscription & Retention Metrics

### 10. Subscription Share

**Definition**: The percentage of total orders that are subscription-based (recurring).

**Formula**:
```r
subscription_share = subscription_orders / total_orders * 100
```

**Example**: 100 total orders / month; 15 are subscriptions = 15% subscription share.

**Why it matters**: 
- Subscriptions = predictable, recurring revenue.
- Higher LTV (lifetime value) than one-time orders.
- Stronger customer loyalty signal.

**TAB target**: Grow from baseline [X]% to 20–25% over 12 months.

---

### 11. Churn Rate

**Definition**: The percentage of subscription customers who cancel in a given period.

**Formula**:
```r
churn_rate = (subscriptions_cancelled_in_month / subscriptions_active_start_of_month) * 100
```

**Example**: 50 active subscriptions at month start; 5 cancel = 10% churn rate.

**Benchmark**:
- Subscription boxes: 5–10% monthly churn (acceptable)
- Grocery: 3–5% (sticky, low price friction)
- Bakery boxes: 5–8% (seasonal patterns, budget shifts)

**How to reduce churn**:
- Consistent quality (fresh bread every week)
- Easy pause/skip (not forced cancellation)
- Win-back campaigns (re-engage lapsed subs)
- Loyalty rewards (5+ orders → 10% discount)

---

### 12. Repeat Purchase Rate

**Definition**: The percentage of customers who make more than one purchase.

**Formula**:
```r
repeat_rate = customers_with_2plus_orders / total_customers * 100
```

**Example**: 100 total customers; 35 have made 2+ purchases = 35% repeat rate.

**Why it matters**: Higher repeat rate = stronger brand loyalty, lower CAC per transaction over time.

**TAB target**: 40–50% repeat rate (1 in 2 customers come back).

---

## Regional & Product Metrics

### 13. Revenue by Region

**Definition**: Total revenue from each geographic region.

**Formula**:
```r
revenue_by_region <- orders %>%
  group_by(region) %>%
  summarise(revenue = sum(revenue))
```

**Why it matters**:
- Identifies strongest/weakest markets.
- Guides paid ad geo-targeting and inventory allocation.

**TAB interpretation**:
- If Newcastle = 60% revenue, focus growth in under-penetrated regions.
- Consider local delivery speed and logistics for each region.

---

### 14. Orders by Region

**Definition**: Number of orders from each region.

**Why it differs from revenue**: A region might have high order count but low AOV (many small orders). Or vice versa.

**Use**: Combined with revenue to calculate AOV by region.

```r
aov_by_region = revenue_by_region / orders_by_region
```

---

## Seasonality Metrics

### 15. Seasonality Index

**Definition**: Ratio of a month's revenue to annual average, showing peak/trough patterns.

**Formula**:
```r
seasonality_index = month_revenue / average_monthly_revenue * 100
```

**Example**: 
- Average monthly revenue = £1,000
- April (Easter) revenue = £1,400
- Seasonality index = 140 (40% above average)

**TAB pattern**:
- Easter (March–April): +20–40% uplift
- Christmas (October–November): +30–50% uplift
- Summer (July–August): -10–20% dip

---

## A/B Testing Metrics

### 16. Test Uplift

**Definition**: The relative improvement in a metric between control and treatment variants.

**Formula**:
```r
uplift_percent = ((treatment_metric - control_metric) / control_metric) * 100
```

**Example**: 
- Control CVR: 2.5%
- Test (new checkout page) CVR: 3.0%
- Uplift: ((3.0 - 2.5) / 2.5) * 100 = +20% uplift

**Statistical significance**: Uplift only matters if it's statistically significant (p < 0.05). Don't declare winner on small sample sizes.

---

## Financial Metrics

### 17. Gross Margin

**Definition**: Revenue minus cost of goods sold (COGS), as a percentage.

**Formula**:
```r
gross_margin = (revenue - cogs) / revenue * 100
```

**Example**: £10,000 revenue; £3,000 COGS = 70% gross margin.

**Why it matters**: Profit available for operating costs, marketing, and growth.

**TAB estimate**: Artisan bakery typically 65–75% gross margin (flour, yeast, labour, rent already included in COGS).

---

### 18. Customer Lifetime Value (CLV)

**Definition**: Total profit expected from a customer over their entire relationship with TAB.

**Simple formula**:
```r
clv = aov * repeat_rate * average_lifetime_months
```

**Example**:
- AOV: £50
- Repeat rate: 40%
- Average customer lifetime: 24 months
- CLV = £50 * 0.40 * 24 = £480

**Why it matters**: Compare to CAC. If CAC > CLV, the channel is unprofitable long-term.

---

## Forecast Metrics

### 19. Growth Rate (Monthly)

**Definition**: The assumed month-on-month percentage increase in MALC (or revenue).

**Scenarios**:
- **Low**: 2% monthly = (1.02 ^ 12) = 26.8% annual growth
- **Base**: 4% monthly = (1.04 ^ 12) = 60.1% annual growth
- **High**: 6% monthly = (1.06 ^ 12) = 101.2% annual growth

**Formula** (for 12 months):
```r
value_at_12_months = baseline_value * (1 + growth_rate) ^ 12
```

---

## Summary Table: Which Metric for What Decision?

| Decision | Metric | Action |
|----------|--------|--------|
| "Should I increase paid ad spend?" | ROAS | If ROAS > 3.0, increase budget |
| "Which channel should I prioritize?" | ROAS + CAC | High ROAS + low CAC = priority |
| "Is my website converting?" | CVR | Low CVR (<2%) = audit UX, checkout |
| "How many customers do I have?" | MALC | Primary North Star |
| "Are customers coming back?" | Repeat rate, subscription share | <30% repeat = retention problem |
| "What's the impact of my seasonal campaign?" | Seasonality index | Plan campaigns 6–8 weeks ahead |
| "Is my acquisition strategy sustainable?" | CAC vs CLV | CAC should be <25% of CLV |
| "What's my revenue forecast?" | Growth rate scenario | Use Base (4%) for conservative planning |

---

## Common Mistakes to Avoid

1. **Conflating MALC with revenue**: High MALC doesn't guarantee high revenue if AOV is low.
2. **Ignoring ROAS threshold**: Marketing spend below 2.0x ROAS is often unprofitable.
3. **Over-optimizing CVR**: Sometimes lower traffic at higher CVR is better than high traffic at low CVR.
4. **Seasonal blindness**: Ignoring Easter/Xmas spikes leads to under-staffing and lost revenue.
5. **CAC isolation**: Don't measure CAC without considering CLV and repeat purchase behaviour.

---

**Questions?** Refer to the R scripts for exact calculation code, or review the report sections for business interpretation.

