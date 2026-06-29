**Aviation Operations & Movement Analytics**

A comprehensive data analysis and performance optimization project focused on airport traffic modeling, capacity analysis, and delay tracking. Utilizing SQL Server, this project aggregates raw tower logs and airport metadata to extract critical operational insights—such as movement distributions, wake turbulence profiling, and schedule compliance.

**Tech Stack & Methodology**

**Database Engine:** Microsoft SQL Server (T-SQL)

**Optimization Techniques:** Indexing, CTEs, Window Functions (SUM() OVER), and query modularization to handle high-cardinality COUNT(DISTINCT) aggregates.

Performance Monitoring: STATISTICS IO and STATISTICS TIME execution plan tuning.

📊 **Core Insights & Analytical Scopes**


The project extracts and computes the following key metrics:

| TotalMovements | TotalArrivals% | TotaDeparture% | TotalOperationalAirports | EOBT (on time and Ealry) |
| --- | --- | --- | --- | --- |
| 360,185 | 35.9 | 36.09| 21 | 79.88% |




1. EOPT Compliance for departures

<img width="261" height="79" alt="image" src="https://github.com/user-attachments/assets/6d83653f-0f26-4dfb-b526-caf88d2b5929" />



Departures Over Time: High-level temporal analysis to identify long-term growth and seasonal trends.

Arrivals & Departures per Month: Monthly seasonality profiling to assist in seasonal airport resource allocation.

Running Total Over Time: Cumulative traffic tracking utilizing advanced T-SQL window functions.

2. Airport Capacity & Efficiency Distribution
Movements per Airport: Pure volume distribution by facility (e.g., handling major hubs down to regional airfields).

Percentage of Movements by Airport: Individual airport traffic share calculated efficiently using a single-pass SUM() OVER() window function to minimize database reads.

Busiest Route: Identification of primary city-pairs and high-density air corridors.

3. Flight & Compliance Profiling
IFR/VFR Count: Split between Instrument Flight Rules and Visual Flight Rules to evaluate air traffic control workload and weather impacts.

Landings per WTC (Wake Turbulence Category): Categorization of traffic by aircraft weight variants (Light, Medium, Heavy, Super) to assess runway occupancy and separation constraints.

EOBT Compliance: Evaluation of Estimated Off-Block Time compliance rates to track airline scheduling discipline.

Delay Reasons: Categorized Pareto analysis of operational bottlenecks (e.g., slots, weather, technical, or ATFM delays).

4. Comprehensive Airport Performance Summary
A unified, consolidated view matching airport metadata with aggregated operational logs:

Geographic Profile: Airport Name, City, and Altitude.

Throughput & Delay Constraints: Total Landings, Max Delay, Min Delay, and Average Delay metrics.

Network Variety: High-cardinality metrics tracking the number of unique Airlines Operating, unique Routes, and distinct Aircraft Types Operating per facility.
