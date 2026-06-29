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



 2. Departues and Arrivals over time

<img width="213" height="367" alt="image" src="https://github.com/user-attachments/assets/ae012370-e62f-45ca-926a-9b8ad9dc7ebe" />
<img width="180" height="369" alt="image" src="https://github.com/user-attachments/assets/96dd9559-93a4-45f7-a215-40efe64d4edc" />

3. Movements Per Airport
   
<img width="343" height="363" alt="image" src="https://github.com/user-attachments/assets/73b5ac27-be6b-4c95-ad80-94917e832ae1" />

5. Percentage Movements for each Airport
   
<img width="559" height="363" alt="image" src="https://github.com/user-attachments/assets/840dd707-f0b8-4995-8246-296736739f56" />

7. Tower log type by Airports
   
<img width="427" height="363" alt="image" src="https://github.com/user-attachments/assets/364a300e-6b3f-4f32-9c03-adcedc9a898b" />

9. Movemts in IFR/VFR for each airport
    
<img width="402" height="360" alt="image" src="https://github.com/user-attachments/assets/d73c5cdd-f5a6-4fd0-9493-7e767482a396" />

10. Movemnts WTC for each airport
    
<img width="474" height="362" alt="image" src="https://github.com/user-attachments/assets/081128b6-db83-4ae1-9c8e-7b7a73c3fa11" />

11. Delay reasons, delay time and total delays

<img width="285" height="362" alt="image" src="https://github.com/user-attachments/assets/ebfc649f-aaad-4521-a8ac-5f18a1467d00" />

12. 10 Busiest routes

<img width="285" height="362" alt="image" src="https://github.com/user-attachments/assets/2a63d470-fa9b-4edd-8585-cc19ab265ae2" />

13. Summary of Operations per Airport

<img width="882" height="368" alt="image" src="https://github.com/user-attachments/assets/4161e223-7aea-4337-8a4b-60f5168ad729" />











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
