"""Compile the academic Rmd into a pandoc-friendly markdown that does not
require R to render. Strips R code chunks but keeps include_graphics calls
(with figure captions), preserves markdown tables, and removes the "Figure N:"
prefixes from captions so pandoc's auto-numbering does not duplicate them.

Run from the project root:
  python3 scripts/rmd_to_md.py > output/report.md

This is invoked automatically by scripts/RUN_ALL.R when R is unavailable.
"""
import re
from pathlib import Path

RMD = Path("ISO8005_TAB_Report.Rmd")
src = RMD.read_text()

# Strip YAML front-matter; the metadata is supplied by scripts/metadata.yaml.
src = re.sub(r"^---[\s\S]*?---\n", "", src, count=1)

SMART_TABLE = """
| Objective | KPI | Target | Deadline | Evidence |
|---|---|---|---|---|
| Grow the local digital customer base | MALC | +60% (430 -> ~690) | Feb 2027 | `malc` monthly |
| Improve site-wide conversion | CVR | >= 3.0% | End Q3 2026 | `orders/website_sessions` |
| Build repeat revenue (subscriptions) | Active subscriptions | >= 700 active subs | End Q4 2026 | `active_subscriptions` |
| Optimise paid efficiency | Blended ROAS | >= 1.5x blended | End Q2 2026 | `revenue/total_ad_spend` |
| Build an owned marketing channel | Email list size | >= 2,500 sign-ups | End Q2 2026 | `email_signups` |

Table: SMART objectives mapped to KPIs and dataset evidence.
"""

DASH_TABLE = """
| Tile | Metrics | Tools | Cadence | Owner | Action threshold |
|---|---|---|---|---|---|
| Acquisition | Sessions, users, share by channel | GA4 + Looker Studio | Weekly | Founder | Organic share < 30% => SEO push |
| Conversion | CVR, AOV, cart-abandonment | GA4 + Shopify | Weekly | Founder | CVR < 2.5% => next A/B test |
| Paid efficiency | Spend, ROAS, CAC by platform | Google/Meta/TikTok APIs | Weekly | Agency / founder | ROAS < 1.0x => pause |
| Retention | Active subs, churn, repeat rate | Klaviyo + Shopify | Weekly | Founder | Churn > 5% => win-back |
| Content | Posts, engagements, clicks to site | Meta/TikTok APIs | Weekly | Social assistant | Engagement < 2% => pillar review |

Table: Weekly dashboard specification with owners, cadence and action thresholds.
"""

PAID_TABLE = """
| Channel | Spend (GBP) | Clicks | CTR | CPC | Conv. | ROAS | CAC |
|---|---|---|---|---|---|---|---|
| Google | 34,204 | 75,830 | 4.04% | 0.45 | 929 | 1.14x | 36.82 |
| TikTok | 12,577 | 24,561 | 1.81% | 0.51 | 289 | 0.90x | 43.52 |
| Meta | 42,467 | 75,243 | 1.62% | 0.56 | 931 | 0.82x | 45.61 |
| Other | 6,105 | 10,601 | 1.07% | 0.58 | 117 | 0.62x | 52.18 |

Table: Paid channel performance across Mar 2024 - Feb 2026 (computed in script 02).
"""

FCAST_TABLE = """
| Scenario | M+3 | M+6 | M+9 | M+12 | Revenue M+12 (GBP) | Delta vs baseline |
|---|---|---|---|---|---|---|
| Low (+2%/mo) | 456 | 484 | 513 | 545 | 11,094 | +27% |
| Base (+4%/mo) | 484 | 544 | 612 | 688 | 14,008 | +60% |
| High (+6%/mo) | 512 | 610 | 726 | 865 | 17,615 | +101% |

Table: Forecast outputs by scenario. MALC values are integer customers; revenue is computed at AOV £20.34.
"""

ROADMAP_TABLE = """
| Quarter | Focus | MALC uplift | Budget |
|---|---|---|---|
| Q1 | Shopify MVP launch, GA4 + Klaviyo wiring, email capture, A/B winner | +5-8% | £2,000 |
| Q2 | SEO/blog programme; Bread Box LP; subscription gifting test | +8-12% | £2,500 |
| Q3 | Budget reallocation by ROAS; PDP optimisation; retention flows | +10-15% | £3,000 |
| Q4 | Christmas campaign; loyalty tier; subscription gifting; review | +15-20% | £4,000 |

Table: Quarterly roadmap with expected MALC uplift and indicative budget.
"""

def chunk_replace(m):
    head, body = m.group(1), m.group(2)
    cap_m = re.search(r'fig\.cap\s*=\s*"([^"]+)"', head)
    cap = cap_m.group(1) if cap_m else None
    img_m = re.search(r'include_graphics\("([^"]+)"\)', body)
    if img_m:
        path = img_m.group(1)
        # Drop the "Figure N: " prefix so pandoc auto-numbering doesn't double
        if cap:
            cap_clean = re.sub(r'^Figure\s+\d+[:.]?\s*', '', cap)
        else:
            cap_clean = ""
        return f'\n![{cap_clean}]({path}){{width=95%}}\n'
    if "smart <- tibble"   in body: return SMART_TABLE
    if "dash <- tibble"    in body: return DASH_TABLE
    if "paid_tbl <- tibble" in body: return PAID_TABLE
    if "fcast <- tibble"   in body: return FCAST_TABLE
    if "roadmap <- tibble" in body: return ROADMAP_TABLE
    if "echo=TRUE" in head and "eval=FALSE" in head:
        return "\n```r\n" + body.strip() + "\n```\n"
    return ""

src = re.sub(r"```\{r([^}]*)\}\n([\s\S]*?)```", chunk_replace, src)

# Print to stdout (caller pipes to output/report.md)
import sys
sys.stdout.write(src)
