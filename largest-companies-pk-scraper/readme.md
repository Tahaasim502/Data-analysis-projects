# Largest Companies in Pakistan — Web Scraper

Scrapes Wikipedia's "List of largest companies in Pakistan" page to extract:
- Major business groups and their subsidiaries
- Top 20 companies by market capitalization

## Tools
- Python, BeautifulSoup, Requests, Pandas

## What it does
1. Fetches the Wikipedia page with a proper User-Agent header
2. Parses HTML tables using BeautifulSoup
3. Cleans extracted data (removes citation references, fixes encoding issues)
4. Exports clean data to CSV using Pandas

## Output
- `data/largest_companies.csv` — business groups and subsidiaries
- `data/largest_companies_marketcap.csv` — top 20 companies by market cap

## Run it
\```
pip install -r requirements.txt
jupyter notebook scraper.ipynb
\```